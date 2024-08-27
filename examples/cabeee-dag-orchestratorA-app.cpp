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

//#include <ndn-cxx/security/validator-config.hpp>

// Enclosing code in ndn simplifies coding (can also use `using namespace ndn`)
namespace ndn {
// Additional nested namespaces should be used to prevent/limit name conflicts
namespace examples {

class OrchestratorA
{
public:
  //OrchestratorA()
  //{
    //m_validator.load("/home/cabeee/mini-ndn/dl/ndn-cxx/examples/cabeee-trust-schema.conf");
  //}

  void
  run(char* PREFIX, char* servicePrefix)
  {
    m_PREFIX = PREFIX;
    std::string fullPrefix(PREFIX);
    fullPrefix.append(servicePrefix);
    //m_name = servicePrefix;
    //m_service = servicePrefix;
    std::cout << "OrchestratorA listening to: " << fullPrefix << '\n';
    m_face.setInterestFilter(fullPrefix,
                             std::bind(&OrchestratorA::onInterest, this, _2),
                             nullptr, // RegisterPrefixSuccessCallback is optional
                             std::bind(&OrchestratorA::onRegisterFailed, this, _1, _2));

    auto cert = m_keyChain.getPib().getDefaultIdentity().getDefaultKey().getDefaultCertificate();
    m_certServeHandle = m_face.setInterestFilter(security::extractIdentityFromCertName(cert.getName()),
                                                 [this, cert] (auto&&...) {
                                                   m_face.put(cert);
                                                 },
                                                 std::bind(&OrchestratorA::onRegisterFailed, this, _1, _2));
    m_face.processEvents();
  }






private:
  void
  sendInterest(const std::string& interestName, std::string dagString)
  {

    /////////////////////////////////////
    // Sending one Interest packet out //
    /////////////////////////////////////

    //std::cout << "Should send new interest now" << std::endl;



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

    //std::cout << "OrchestratorA: Sending Interest packet for " << interest << std::endl;

    m_face.expressInterest(interest,
                           std::bind(&OrchestratorA::onData, this,  _1, _2),
                           std::bind(&OrchestratorA::onNack, this, _1, _2),
                           std::bind(&OrchestratorA::onTimeout, this, _1));

    // we need to prevent this from blocking! If more than one interest will be generated, we want both to be sent out at the same time!
    m_face.processEvents(ndn::time::milliseconds(-1)); // If a negative timeout is specified, then processEvents will not block and will process only pending events.

  }







private:
  void
  onInterest(const Interest& interest)
  {
    //std::cout << ">> I: " << interest << std::endl;

    std::string resetPrefix(m_PREFIX);
    resetPrefix.append("/serviceOrchestration/reset");
    if (interest.getName() == resetPrefix)
    {
      //reset variables, generate data packet response and return
      //std::cout << "<< Orchestrator received interest to reset data structures!" << std::endl;
      m_dagOrchTracker.clear();
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
      //std::cout << "<< D: " << *data << std::endl;
      m_face.put(*data);

      return;
    }

    // decode the DAG string contained in the application parameters, so we can generate the new interest(s)
    //extract custom parameter from interest packet
    auto dagParameterFromInterest = interest.getApplicationParameters();
    std::string dagString = std::string(reinterpret_cast<const char*>(dagParameterFromInterest.value()), dagParameterFromInterest.value_size());


    //bool dagParameterDigestValid = interest.isParametersDigestValid();
    //std::cout << "Fwd: Interest parameter digest is valid: " << dagParameterDigestValid << std::endl;
    //bool dagParameterPresent = interest.hasApplicationParameters();
    //std::cout << "Fwd: Interest parameters presesnt: " << dagParameterPresent << std::endl;


    // read the dag parameters and figure out which interests to generate next. Change the dagParameters accordingly (head will be different)
    m_dagObject = json::parse(dagString);
    //std::cout << ("Interest parameter head: " << dagObject["head"] << ", m_name attribute: " << m_name.ndn::Name::toUri());
    //if (dagObject["head"] != m_name.ndn::Name::toUri())
    //{
      //std::cout << ("OrchestratorA app ERROR: received interest with DAG head different than m_name attribute for this service.");
      //std::cout << ("Interest parameter head: " << dagObject["head"] << ", m_name attribute: " << m_name.ndn::Name::toUri());
    //}
    //std::cout << ("Interest parameter number of services: " << dagObject["dag"].size());
    //std::cout << ("Interest parameter sensor feeds " << (dagObject["dag"]["/sensor"].size()) << " services: " << dagObject["dag"]["/sensor"]);
    //std::cout << ("Interest parameter s1 feeds " << (dagObject["dag"]["/S1"].size()) << " services: " << dagObject["dag"]["/S1"]);

    //std::cout << "Full DAG as received: " << std::setw(2) << m_dagObject << std::endl;



    // here we generate just the first interest(s) according to the workflow (not backwards as done in our proposed forwarder-based methodology).
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
    }
    //std::cout << std::setw(2) << m_dagOrchTracker << '\n';
    for (auto& x : m_dagObject["dag"].items())
    {
      for (auto& y : m_dagObject["dag"][x.key()].items())
      {
        if ((std::find(m_listOfSinkNodes.begin(), m_listOfSinkNodes.end(), y.key()) == m_listOfSinkNodes.end())) // if y.key() does not exist in m_listOfSinkNodes
        {
          m_dagOrchTracker[(std::string)y.key()]["inputsRxed"][(std::string)x.key()] = 0;
          //std::cout << "x.key is " << x.key() << ", and y.key is " << y.key() << '\n';
        }
      }
    }
    //std::cout << "OrchestratorA dagOrchTracker data structure: " << std::setw(2) << m_dagOrchTracker << '\n';


    for (auto rootService : m_listOfRootServices)
    {
      // generate new interest for root services if one has not yet been generated
      //std::cout << "Generating interest for: " << rootService << std::endl;

      // We need to see if this interest has already been generated. If so, don't increment
      // if this is a new interest (if interest is not in our list of generated interests)
      //if ((std::find(m_listOfGeneratedInterests.begin(), m_listOfGeneratedInterests.end(), rootService) == m_listOfGeneratedInterests.end())) { // if we don't find it...
        // add this new interest to list of generated interests
        //m_listOfGeneratedInterests.push_back(rootService);
        sendInterest(rootService, dagString);
        m_dagOrchTracker[rootService]["interestGenerated"] = 1;
      //}
    }



    m_nameAndDigest = interest.getName();  // store the name with digest so that we can later generate the final result data packet with the same name/digest!

  }





private:
  void
  onData(const Interest&, const Data& data)
  {
    //std::cout << "Received Data: " << data << std::endl;
    //std::cout << "Data Content: " << data.getContent().value() << std::endl;



    ndn::Block myRxedBlock = data.getContent();
    uint8_t *pContent = (uint8_t *)(myRxedBlock.data()); // this points to the first byte, which is the TLV-TYPE (21 for data packet contet)
    pContent++;  // now this points to the second byte, containing 253 (0xFD), meaning size (1024) is expressed with 2 octets
    pContent++;  // now this points to the first size octet
    pContent++;  // now this points to the second size octet
    pContent++;  // now we are pointing at the first byte of the true content
    //std::cout << "\n  The received data value is: " <<  (int)(*pContent) << std::endl << "\n\n";
    /*
    m_validator.validate(data,
                         [] (const Data&) {
                           std::cout << "Data conforms to trust schema" << std::endl;
                         },
                         [] (const Data&, const security::ValidationError& error) {
                           std::cout << "Error authenticating data: " << error << std::endl;
                         });
    */



    ndn::Name simpleName;
    simpleName = (data.getName()).getPrefix(-1); // remove the last component of the name (the parameter digest) so we have just the raw name, and convert to Uri string
    simpleName = simpleName.getSubName(1); // remove the first component of the name (/interCACHE)
    //std::string rxedDataName = (data.getName()).getPrefix(-1).toUri(); // remove the last component of the name (the parameter digest) so we have just the raw name
    std::string rxedDataName = simpleName.toUri();


    // mark down this input as having been received for all services that use this data as an input
    for (auto& service : m_dagOrchTracker.items())
    {
      for (auto& serviceInput : m_dagOrchTracker[(std::string)service.key()]["inputsRxed"].items())
      {
        if (serviceInput.key() == rxedDataName)
        {
          serviceInput.value() = 1;
        }
      }
    }
    //std::cout << "Updated dagTracker data structure: " << std::setw(2) << m_dagOrchTracker << '\n';





    // now we check to see which services that we have not generated interests for yet have all their inputs satisfied, and generate new interest if satisfied.
    // note there might be more than one service that needs to run next (ex: in the RPA DAG, when we receive R1, we can now run S2 AND S3)
    for (auto& service : m_dagOrchTracker.items())  // for each service in the tracker
    {
      if (service.value()["interestGenerated"] == 0)  // if we haven't generated an interest for this service, then analyze its rxed inputs
      {
        unsigned char allInputsReceived = 1;
        for (auto& serviceInput : m_dagOrchTracker[(std::string)service.key()]["inputsRxed"].items())
        {
          if (serviceInput.value() == 0)
          {
            allInputsReceived = 0;
            break;
          }
        }
        if (allInputsReceived == 1)
        {
          // generate the interest for this service, and mark it down as generated
          std::string dagString = m_dagObject.dump();
          sendInterest(service.key(), dagString);
          service.value()["interestGenerated"] = 1;
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
          //std::cout << "Final data packet! Creating data for name: " << m_nameAndDigest << std::endl;   // m_name doesn't have the sha256 digest, so it doesn't match the original interest!
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
          //std::cout << "<< D: " << *new_data << std::endl;
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
  //ValidatorConfig m_validator{m_face};
  KeyChain m_keyChain;
  ScopedRegisteredPrefixHandle m_certServeHandle;

  char* m_PREFIX;

  //ndn::Name m_name;
  //std::string m_nameUri;
  ndn::Name m_nameAndDigest;
  //ndn::Name m_service;
  json m_dagOrchTracker; // with this data structure, we can keep track of WHICH inputs have arrived, rather than just the NUMBER of inputs. (in case one inputs arrives multiple times)
  json m_dagObject;
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
    ndn::examples::OrchestratorA orchestratorA;
    orchestratorA.run(argv[1], argv[2]);
    return 0;
  }
  catch (const std::exception& e) {
    std::cerr << "ERROR: " << e.what() << std::endl;
    return 1;
  }
}
