/* -*- Mode:C++; c-file-style:"gnu"; indent-tabs-mode:nil; -*- */
/*
 * Copyright (c) 2013-2023 Regents of the University of California.
 *
 * This file is part of ndn-cxx library (NDN C++ library with eXperimental eXtensions).
 *
 * ndn-cxx library is free software: you can redistribute it and/or modify it under the
 * terms of the GNU Lesser General Public License as published by the Free Software
 * Foundation, either version 3 of the License, or (at your option) any later version.
 *
 * ndn-cxx library is distributed in the hope that it will be useful, but WITHOUT ANY
 * WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
 * PARTICULAR PURPOSE.  See the GNU Lesser General Public License for more details.
 *
 * You should have received copies of the GNU General Public License and GNU Lesser
 * General Public License along with ndn-cxx, e.g., in COPYING.md file.  If not, see
 * <http://www.gnu.org/licenses/>.
 *
 * See AUTHORS.md for complete list of ndn-cxx authors and contributors.
 */

#include <ndn-cxx/face.hpp>
#include <ndn-cxx/security/key-chain.hpp>
#include <ndn-cxx/security/signing-helpers.hpp>

#include <iostream>
#include <ndn-cxx/util/io.hpp>

#include <nlohmann/json.hpp>
using json = nlohmann::json;

#include <ndn-cxx/security/validator-config.hpp>

// Enclosing code in ndn simplifies coding (can also use `using namespace ndn`)
namespace ndn {
// Additional nested namespaces should be used to prevent/limit name conflicts
namespace examples {

class OrchestratorB
{
public:
  OrchestratorB()
  {
    m_validator.load("/home/cabeee/mini-ndn/dl/ndn-cxx/examples/cabeee-trust-schema.conf");
  }

  void
  run(char* PREFIX, char* servicePrefix)
  {
    m_PREFIX = PREFIX;
    std::string fullPrefix(PREFIX);
    fullPrefix.append(servicePrefix);
    //m_name = servicePrefix;
    //m_service = servicePrefix;
    std::cout << "OrchestratorB listening to: " << fullPrefix << '\n';
    m_serviceInputIndex = 0;
    m_face.setInterestFilter(fullPrefix,
                             std::bind(&OrchestratorB::onInterest, this, _2),
                             nullptr, // RegisterPrefixSuccessCallback is optional
                             std::bind(&OrchestratorB::onRegisterFailed, this, _1, _2));

    auto cert = m_keyChain.getPib().getDefaultIdentity().getDefaultKey().getDefaultCertificate();
    m_certServeHandle = m_face.setInterestFilter(security::extractIdentityFromCertName(cert.getName()),
                                                 [this, cert] (auto&&...) {
                                                   m_face.put(cert);
                                                 },
                                                 std::bind(&OrchestratorB::onRegisterFailed, this, _1, _2));
    m_face.processEvents();
  }






private:
  void
  sendInterest(const std::string& interestName, std::string dagString)
  {

    /////////////////////////////////////
    // Sending one Interest packet out //
    /////////////////////////////////////

    std::cout << "Should send new interest now" << std::endl;



    Interest interest(m_PREFIX + interestName);
    //interest.setMustBeFresh(true);
    interest.setInterestLifetime(6_s); // The default is 4 seconds

    // overwrite the dag parameter "head" value and generate new application parameters (thus calculating new sha256 digest)
    //std::string dagString = std::string(reinterpret_cast<const char*>(dagParameter.value()), dagParameter.value_size());
    auto dagObject = json::parse(dagString);
    //std::cout << "\n\n\n\n\n\n\n\n\n\n\n\nStarting new SendInterest for " << interestName << '\n';
    //std::cout << "Full DAG as received: " << std::setw(2) << dagObject << '\n';
    dagObject["head"] = interestName;
    //std::cout << "Pruned DAG with new head name: " << std::setw(2) << dagObject << '\n';
    std::string updatedDagString = dagObject.dump();
    //std::cout << "updatedDagString: " << updatedDagString << std::endl;

    std::shared_ptr<Buffer> dagApplicationParameters;
    std::istringstream is(updatedDagString);
    dagApplicationParameters = io::loadBuffer(is, io::NO_ENCODING);

    //add modified DAG workflow as a parameter to the new interest
    interest.setApplicationParameters(dagApplicationParameters);

    std::cout << "OrchestratorB: Sending Interest packet for " << interest << std::endl;

    m_face.expressInterest(interest,
                           std::bind(&OrchestratorB::onData, this,  _1, _2),
                           std::bind(&OrchestratorB::onNack, this, _1, _2),
                           std::bind(&OrchestratorB::onTimeout, this, _1));

    // we need to prevent this from blocking! If more than one interest will be generated, we want both to be sent out at the same time!
    m_face.processEvents(ndn::time::milliseconds(-1)); // If a negative timeout is specified, then processEvents will not block and will process only pending events.

  }







private:
  void
  onInterest(const Interest& interest)
  {
    std::cout << ">> I: " << interest << std::endl;

    if (interest.getName() == "/interCACHE/serviceOrchestration/reset") // TODO: don't hardcode the PREFIX
    {
      //reset variables, generate data packet response and return
      std::cout << "<< Orchestrator received interest to reset data structures!" << std::endl;
      m_dagOrchTracker.clear();
      m_vectorOfServiceInputs.clear();
      m_serviceInputIndex = 0;
      m_listOfServicesWithInputs.clear();
      m_listOfRootServices.clear();
      m_listOfSinkNodes.clear();

      // Create Data packet
      auto data = std::make_shared<Data>();
      data->setName(interest.getName());
      data->setFreshnessPeriod(10_s);
      data->setContent("Orchestrator data structures have been reset!"); // the content of this data message is not important. We just want to respond to clear out PIT entries
      m_keyChain.sign(*data, signingWithSha256());
      // Return Data packet to the requester
      std::cout << "<< D: " << *data << std::endl;
      m_face.put(*data);

      return;
    }


    ndn::Name nameAndDigest = interest.getName();
    std::string nameUri = nameAndDigest.getSubName(1,2).toUri(); // extract 2 components starting from component 1, and then convert to Uri string
    std::cout << "Received Interest packet for " << nameUri << ", full name with digest: " << nameAndDigest << std::endl;

    if (nameUri == "/serviceOrchestration/dag") // if interest is for orchestration (from consumer)
    {
      m_nameAndDigest = interest.getName();  // store the name with digest so that we can later generate the final result data packet with the same name/digest!

      // decode the DAG string contained in the application parameters, so we can generate the new interest(s)
      //extract custom parameter from interest packet
      auto dagParameterFromInterest = interest.getApplicationParameters();
      std::string dagString = std::string(reinterpret_cast<const char*>(dagParameterFromInterest.value()), dagParameterFromInterest.value_size());


      // read the dag parameters and figure out which interest(s) to generate (only for those that don't have inputs coming from other services - "root" services).
      m_dagObject = json::parse(dagString);


      // here we generate just the first interest(s) according to the workflow (not backwards as done originally in our proposed forwarder-based methodology).
      // to do this, we must discover which services in the DAG are "root" services (services which don't have inputs coming from other services, for example: sensors).


      for (auto& x : m_dagObject["dag"].items())
      {
        m_listOfRootServices.push_back(x.key()); // for now, add ALL keys to the list, we'll remove non-root ones later
        for (auto& y : m_dagObject["dag"][x.key()].items())
        {
          m_listOfServicesWithInputs.push_back(y.key()); // add all values to the list
          if ((std::find(m_listOfSinkNodes.begin(), m_listOfSinkNodes.end(), y.key()) == m_listOfSinkNodes.end())) // if y.key() does not exist in m_listOfSinkNodes
          {
            m_listOfSinkNodes.push_back(y.key()); // for now, add ALL values to the list, we'll remove non-sinks later
          }
        }
      }

      // now remove services that feed into other services from the list of sink nodes
      for (auto& x : m_dagObject["dag"].items())
      {
        if (!(std::find(m_listOfSinkNodes.begin(), m_listOfSinkNodes.end(), x.key()) == m_listOfSinkNodes.end())) // if x.key() exists in m_listOfSinkNodes
        {
          m_listOfSinkNodes.remove(x.key());
        }
      }

      // now remove services that have other services as inputs from the list of root services
      for (auto serviceWithInputs : m_listOfServicesWithInputs)
      {
        if (!(std::find(m_listOfRootServices.begin(), m_listOfRootServices.end(), serviceWithInputs) == m_listOfRootServices.end())) // if serviceWithInputs exists in m_listOfRootServices
        {
          m_listOfRootServices.remove(serviceWithInputs);
        }
      }




      // create the tracking data structure using JSON
      json nullJson;
      for (auto& x : m_dagObject["dag"].items()) // first pass just gets the source services (don't worry what they feed)
      {
        unsigned char isRoot = 0;
        if (!(std::find(m_listOfRootServices.begin(), m_listOfRootServices.end(), x.key()) == m_listOfRootServices.end())) // if x.key() exists in m_listOfRootServices
          isRoot = 1;
        m_dagOrchTracker.push_back( json::object_t::value_type(x.key(), {{"root", isRoot}} ) );
        m_dagOrchTracker[x.key()].push_back( json::object_t::value_type("interestGenerated", 0 ) );
        m_dagOrchTracker[x.key()].push_back( json::object_t::value_type("inputsRxed", nullJson ) );
        m_dagOrchTracker[x.key()].push_back( json::object_t::value_type("inputsTxed", nullJson ) );
      }
      //std::cout << std::setw(2) << m_dagOrchTracker << '\n';
      for (auto& x : m_dagObject["dag"].items())
      {
        for (auto& y : m_dagObject["dag"][x.key()].items())
        {
          if ((std::find(m_listOfSinkNodes.begin(), m_listOfSinkNodes.end(), y.key()) == m_listOfSinkNodes.end())) // if y.key() does not exist in m_listOfSinkNodes
          {
            m_dagOrchTracker[(std::string)y.key()]["inputsRxed"][(std::string)x.key()] = -1;
            m_dagOrchTracker[(std::string)y.key()]["inputsTxed"][(std::string)x.key()] = 0;
            //std::cout << "x.key is " << x.key() << ", and y.key is " << y.key() << '\n';
          }
        }
      }
      //std::cout << "OrchestratorB dagOrchTracker data structure: " << std::setw(2) << m_dagOrchTracker << '\n';


      for (auto rootService : m_listOfRootServices)
      {
        // generate new interest for root services if one has not yet been generated
        std::cout << "Generating interest for: " << rootService << std::endl;

        // We need to see if this interest has already been generated. If so, don't increment
        // if this is a new interest (if interest is not in our list of generated interests)
        //if ((std::find(m_listOfGeneratedInterests.begin(), m_listOfGeneratedInterests.end(), rootService) == m_listOfGeneratedInterests.end())) { // if we don't find it...
          // add this new interest to list of generated interests
          //m_listOfGeneratedInterests.push_back(rootService);
          sendInterest(rootService, dagString);
          m_dagOrchTracker[rootService]["interestGenerated"] = 1;
        //}
      }

    }

    else if (nameUri == "/serviceOrchestration/data") // if interest is for data input to service (from a service)
    {

      // respond with data that was requested

      // look at 3rd and 4th components of the name, for example: /interCACHE/serviceOrchestration/data/sensor/service1 + digest which contains DAG
      // requestedService will be for example /sensor
      // requestorService will be for example /service1
      std::string inputNumString   = nameAndDigest.getSubName(3,1).toUri(); // extract 1 components starting from component 3, and then convert to Uri string
      std::string requestedService = nameAndDigest.getSubName(4,1).toUri(); // extract 1 components starting from component 5, and then convert to Uri string
      std::string requestorService = nameAndDigest.getSubName(5,1).toUri(); // extract 1 components starting from component 5, and then convert to Uri string
      inputNumString = inputNumString.erase(0,1); // remove the "/" at the beginning of the Uri Name, to leave just the number (still as a string)
      unsigned char inputNum = stoi(inputNumString);
      std::cout << "Orchestrator received interest for: " << nameUri << ", service name: " << requestedService << ", stored at index " << inputNumString << ", by requestor: " << requestorService << std::endl;

      // look at data structure and figure out which index is used for the stored result for requestedService
      for (auto& service : m_dagOrchTracker.items())  // for each service in the tracker
      {
        if (service.key() == requestorService)
        {
          std::cout << "Found requestor service!" << std::endl;
          for (auto& serviceInput : m_dagOrchTracker[(std::string)service.key()]["inputsRxed"].items())
          {
            if (serviceInput.key() == requestedService) // there might be more than one service that uses this input, but we already matched to the requestor above.
            {
              std::cout << "Found requested service result!" << std::endl;
              unsigned char inputStorageIndex = serviceInput.value();

              // send that data at that index as a response for this interest
              std::cout << "Generating data packet for: " << nameAndDigest.ndn::Name::toUri() << std::endl;

              // Create new Data packet
              auto new_data = std::make_shared<Data>();
              new_data->setName(nameAndDigest);
              new_data->setFreshnessPeriod(9_s);
              unsigned char myBuffer[1024];
              // write to the buffer
              myBuffer[0] = m_vectorOfServiceInputs[inputStorageIndex];
              new_data->setContent(myBuffer);


              // In order for the consumer application to be able to validate the packet, you need to setup
              // the following keys:
              // 1. Generate example trust anchor
              //
              //         ndnsec key-gen /example
              //         ndnsec cert-dump -i /example > example-trust-anchor.cert
              //
              // 2. Create a key for the producer and sign it with the example trust anchor
              //
              //         ndnsec key-gen /example/testApp
              //         ndnsec sign-req /example/testApp | ndnsec cert-gen -s /example -i example | ndnsec cert-install -

              // Sign Data packet with default identity
              //m_keyChain.sign(*new_data);
              // m_keyChain.sign(*new_data, signingByIdentity(<identityName>));
              // m_keyChain.sign(*new_data, signingByKey(<keyName>));
              // m_keyChain.sign(*new_data, signingByCertificate(<certName>));
              m_keyChain.sign(*new_data, signingWithSha256());

              // Return Data packet to the requester
              std::cout << "<< D: " << *new_data << std::endl;
              m_face.put(*new_data);



              // update tracker data structure to mark data as having been sent (set inputsTxed value to 1)
              m_dagOrchTracker[(std::string)service.key()]["inputsTxed"][(std::string)serviceInput.key()] = 1;
              //std::cout << "Updated dagOrchTracker data structure: " << std::setw(2) << m_dagOrchTracker << '\n';
            }
          }
        }
      }



      // if all data inputs for the downstream service have been sent out, then generate an interest for the service to run
      // we check to see which services that we have not generated interests for yet have all their inputs satisfied (Txed to the service), and generate new interest if satisfied.
      // note there might be more than one service that needs to run next (ex: in the RPA DAG, when we receive R1, we can now send results to (and then run) S2 AND S3)
      for (auto& service : m_dagOrchTracker.items())  // for each service in the tracker
      {
        if (service.value()["interestGenerated"] == 0)  // if we haven't generated an interest for this service, then analyze its rxed inputs
        {
          unsigned char allInputsTxed = 1;
          for (auto& serviceInput : m_dagOrchTracker[(std::string)service.key()]["inputsTxed"].items())
          {
            if (serviceInput.value() == 0)
            {
              allInputsTxed = 0;
              break;
            }
          }
          if (allInputsTxed == 1)
          {
            // generate the interest request for the data inputs for this service, and mark it down as generated
            std::string dagString = m_dagObject.dump();
            sendInterest(service.key(), dagString);
            service.value()["interestGenerated"] = 1;
          }
        }
      }
    }


  }





private:
  void
  onData(const Interest&, const Data& data)
  {
    std::cout << "Received Data: " << data << std::endl;
    std::cout << "Data Content: " << data.getContent().value() << std::endl;


    //std::string rxedDataName = (data.getName()).getPrefix(-1).toUri(); // remove the last component of the name (the parameter digest) so we have just the raw name
    //std::string rxedDataName = (data.getName()).getSubName(1,1).toUri(); // extract 1 component starting from component 1, and then convert to Uri string
    std::string rxedDataName = (data.getName()).getPrefix(-1).getSubName(1).toUri(); // remove the 0th component of the name (/interCACHE PREFIX)
    std::cout << "   Service name is " << rxedDataName << ", using this name to analyze data structure of received inputs.\n";

    std::cout << "Storing the received result at m_vectorOfServiceInputs[" << std::to_string(m_serviceInputIndex) << "]\n";
    // store the received result, so we can later send it to downstream services
    // TODO: this is a HACK. I need a better way to get to the first byte of the content. Right now, I'm just incrementing the pointer past the TLV type, and size.
    // and then getting to the first byte (which is all I'm using for data)
    //unsigned char serviceOutput = 0;
    uint8_t *pServiceInput = 0;
    pServiceInput = (uint8_t *)(data.getContent().data()); // this points to the first byte, which is the TLV-TYPE (21 for data packet content)
    pServiceInput++;  // now this points to the second byte, containing 253 (0xFD), meaning size (1024) is expressed with 2 octets
    pServiceInput++;  // now this points to the first size octet
    pServiceInput++;  // now this points to the second size octet
    pServiceInput++;  // now we are pointing at the first byte of the true content
    //m_mapOfServiceInputs[rxedDataName] = (*pServiceInput);
    m_vectorOfServiceInputs.push_back(*pServiceInput); // add it at the end (should be same as putting it at index m_serviceInputIndex)
    //m_vectorOfServiceInputs[m_serviceInputIndex] = (unsigned char)(*pServiceInput);



    std::cout << "Marking down this input as having been received\n";
    // mark down this input as having been received for all services that use this data as an input
    // default object value is -1 (not received)
    // any other value (0 and up) means it has been received, and has been stored at the index specified by that value
    for (auto& service : m_dagOrchTracker.items())
    {
      for (auto& serviceInput : m_dagOrchTracker[(std::string)service.key()]["inputsRxed"].items())
      {
        if (serviceInput.key() == rxedDataName)
        {
          serviceInput.value() = m_serviceInputIndex;
        }
      }
    }
    std::cout << "Updated dagOrchTracker data structure: " << std::setw(2) << m_dagOrchTracker << '\n';
    m_serviceInputIndex++; // get it ready for the next data input that we receive






    // now we check to see which services that we have not generated interests for yet have all their inputs satisfied, and generate new data request interests if satisfied.
    // note there might be more than one service that needs data request interests generated so they can run next (ex: in the RPA DAG, when we receive R1, we can now run S2 AND S3)
    for (auto& service : m_dagOrchTracker.items())  // for each service in the tracker
    {
      if (service.value()["interestGenerated"] == 0)  // if we haven't generated an interest for this service, then analyze its rxed inputs
      {
        unsigned char allInputsRxed = 1;
        for (auto& serviceInput : m_dagOrchTracker[(std::string)service.key()]["inputsRxed"].items())
        {
          if (serviceInput.value() == -1)
          {
            allInputsRxed = 0;
            break;
          }
        }
        if (allInputsRxed == 1)
        {
          for (auto& serviceInput : m_dagOrchTracker[(std::string)service.key()]["inputsRxed"].items())
          {
            // generate the interest request for the data inputs for this service, (and mark it down as generated?)

            // this data request name will be: "/service1/datarequest/0/sensor" for example to request data for input # 0, which will come from /sensor
            // we need to cross reference the input index number (0 in this case), by searching for this service in the dag workflow data-structure
            // for example for service 4, which has two inputs, I need to generate 2 requests for inputs, and thus need to get their two indices!
            unsigned char inputNum = -1;
            for (auto& dagServiceSource : m_dagObject["dag"].items())
            {
              if (dagServiceSource.key() == serviceInput.key())
              {
                //for (auto& dagServiceFeed : m_dagObject["dag"][dagServiceSource.key()].items())
                //{
                  //if (dagServiceFeed.key() == service.key())
                  //{
                    //inputNum = m_dagObject["dag"][(std::string)dagServiceSource.key()][(std::string)dagServiceFeed.key()];
                    //inputNum = dagServiceFeed.value();
                    inputNum = dagServiceSource.value()[service.key()];
                  //}
                //}
              }
            }
            if (inputNum < 0)
            {
              std::cout << "  Orchestrator ERROR!! inputNum for m_vectorOfServiceInputs cannot be negative! Something went wrong!!" << '\n';
            }
            else
            {
              std::cout << "Generating interest request for data inputs for service " << (std::string)service.key() << '\n';
              std::cout << "Request will have name: " << service.key() << "/dataRequest/" << std::to_string(inputNum) << (std::string)serviceInput.key() << '\n';
              std::string interestRequestName = (std::string)service.key() + "/dataRequest/" + std::to_string(inputNum) + (std::string)serviceInput.key();
              //name = /service1/dataRequest/sensor
              //name = /service.key()/dataRequest/serviceInput.key()
              std::string dagString = m_dagObject.dump();
              sendInterest(interestRequestName, dagString);
              //service.value()["interestGenerated"] = 1; // this is done only AFTER the interest for data is received, data packets are sent to the service, and the interest to run the service is also sent!
            }
          }
        }
      }
    }



    // if the result of the last service has been received, then generate data packet with the final result for the consumer.
    for (auto sinkNode : m_listOfSinkNodes)
    {
      //if this data packet feeds sink node
      //std::cout << "        CHECKING SINK: rxedData is " << rxedDataName << ", and current sink node is " << sinkNode << '\n';
      for (auto& serviceFeed : m_dagObject["dag"][rxedDataName].items())
      {
        if (sinkNode == serviceFeed.key())
        {
          std::cout << "Final data packet! Creating data for name: " << m_nameAndDigest << std::endl;   // m_name doesn't have the sha256 digest, so it doesn't match the original interest!
                                                                                                        // We use m_nameAndDigest to store the old name with the digest.

          // Create new Data packet
          auto new_data = std::make_shared<Data>();
          new_data->setName(m_nameAndDigest);
          new_data->setFreshnessPeriod(9_s);
          new_data->setContent(data.getContent());


          // In order for the consumer application to be able to validate the packet, you need to setup
          // the following keys:
          // 1. Generate example trust anchor
          //
          //         ndnsec key-gen /example
          //         ndnsec cert-dump -i /example > example-trust-anchor.cert
          //
          // 2. Create a key for the producer and sign it with the example trust anchor
          //
          //         ndnsec key-gen /example/testApp
          //         ndnsec sign-req /example/testApp | ndnsec cert-gen -s /example -i example | ndnsec cert-install -

          // Sign Data packet with default identity
          //m_keyChain.sign(*new_data);
          // m_keyChain.sign(*new_data, signingByIdentity(<identityName>));
          // m_keyChain.sign(*new_data, signingByKey(<keyName>));
          // m_keyChain.sign(*new_data, signingByCertificate(<certName>));
          m_keyChain.sign(*new_data, signingWithSha256());

          // Return Data packet to the requester
          std::cout << "<< D: " << *new_data << std::endl;
          m_face.put(*new_data);


        }
      }
    }

  
  }



  void
  onNack(const Interest&, const lp::Nack& nack) const
  {
    std::cout << "Received Nack with reason " << nack.getReason() << std::endl;
  }

  void
  onTimeout(const Interest& interest) const
  {
    std::cout << "Timeout for " << interest << std::endl;
  }


  void
  onRegisterFailed(const Name& prefix, const std::string& reason)
  {
    std::cerr << "ERROR: Failed to register prefix '" << prefix
              << "' with the local forwarder (" << reason << ")\n";
    m_face.shutdown();
  }

private:
  Face m_face;
  ValidatorConfig m_validator{m_face};
  KeyChain m_keyChain;
  ScopedRegisteredPrefixHandle m_certServeHandle;

  char* m_PREFIX;

  //ndn::Name m_name;
  //std::string m_nameUri;
  ndn::Name m_nameAndDigest;
  //ndn::Name m_service;
  json m_dagOrchTracker; // with this data structure, we can keep track of WHICH inputs have arrived, rather than just the NUMBER of inputs. (in case one inputs arrives multiple times)
  json m_dagObject;
  std::vector <unsigned char> m_vectorOfServiceInputs;   // keeps a vector of ALL received results (to feed downstream service inputs)
  unsigned char m_serviceInputIndex;
  std::list <std::string> m_listOfServicesWithInputs;   // keeps track of which services have inputs
  std::list <std::string> m_listOfRootServices;         // keeps track of which services don't have any inputs
  std::list <std::string> m_listOfSinkNodes;            // keeps track of which node doesn't have an output (usually this is just the consumer)
};

} // namespace examples
} // namespace ndn

int
main(int argc, char** argv)
{
  try {
    ndn::examples::OrchestratorB orchestratorB;
    orchestratorB.run(argv[1], argv[2]);
    return 0;
  }
  catch (const std::exception& e) {
    std::cerr << "ERROR: " << e.what() << std::endl;
    return 1;
  }
}
