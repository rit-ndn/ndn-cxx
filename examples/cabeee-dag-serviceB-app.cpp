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

class ServiceB
{
public:
  //ServiceB()
  //{
    //m_validator.load("/home/cabeee/mini-ndn/dl/ndn-cxx/examples/cabeee-trust-schema.conf");
  //}

  void
  run(char* PREFIX, char* servicePrefix)
  {
    m_done = false;
    m_extracted = false;
    m_PREFIX = PREFIX;
    std::string fullPrefix(PREFIX);
    fullPrefix.append(servicePrefix);
    m_name = servicePrefix;
    m_service = servicePrefix;
    m_nameUri = m_name.ndn::Name::toUri();
    std::cout << "ServiceB listening to: " << fullPrefix << '\n';
    m_face.setInterestFilter(fullPrefix,
                             std::bind(&ServiceB::onInterest, this, _2),
                             nullptr, // RegisterPrefixSuccessCallback is optional
                             std::bind(&ServiceB::onRegisterFailed, this, _1, _2));

    auto cert = m_keyChain.getPib().getDefaultIdentity().getDefaultKey().getDefaultCertificate();
    m_certServeHandle = m_face.setInterestFilter(security::extractIdentityFromCertName(cert.getName()),
                                                 [this, cert] (auto&&...) {
                                                   m_face.put(cert);
                                                 },
                                                 std::bind(&ServiceB::onRegisterFailed, this, _1, _2));
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
    std::string updatedDagString = dagObject.dump();
    std::shared_ptr<Buffer> dagApplicationParameters;
    std::istringstream is(updatedDagString);
    dagApplicationParameters = io::loadBuffer(is, io::NO_ENCODING);

    //add modified DAG workflow as a parameter to the new interest
    interest.setApplicationParameters(dagApplicationParameters);

    //std::cout << "ServiceB: Sending Interest packet for " << interest << std::endl;

    m_face.expressInterest(interest,
                           std::bind(&ServiceB::onData, this,  _1, _2),
                           std::bind(&ServiceB::onNack, this, _1, _2),
                           std::bind(&ServiceB::onTimeout, this, _1));

    // we need to prevent this from blocking! If more than one interest will be generated, we want both to be sent out at the same time!
    m_face.processEvents(ndn::time::milliseconds(-1)); // If a negative timeout is specified, then processEvents will not block and will process only pending events.



  }







private:
  void
  onInterest(const Interest& interest)
  {
    //std::cout << ">> I: " << interest << std::endl;

    if (m_extracted == false)
    {
      // extract the NAME of the inputs from the DAG in the interest parameter, and generate new interests for input data

      //extract custom parameter from interest packet
      auto dagParameterFromInterest = interest.getApplicationParameters();
      std::string dagString = std::string(reinterpret_cast<const char*>(dagParameterFromInterest.value()), dagParameterFromInterest.value_size());

      // read the dag parameter and figure out which interests to generate next.
      // if inputs come from other services, Ochestrator must have made sure the service results are already available (received "done" signal)!
      m_dagObject = json::parse(dagString);


      // create the tracking data structure using JSON
      json nullJson;
      //m_dagServTracker[m_nameUri].push_back( json::object_t::value_type("interestGenerated", 0 ) );
      m_dagServTracker[m_nameUri].push_back( json::object_t::value_type("inputsRxed", nullJson ) );
      for (auto& x : m_dagObject["dag"].items())
      {
        for (auto& y : m_dagObject["dag"][x.key()].items())
        {
          if (y.key() == m_nameUri)
          {
            m_dagServTracker[(std::string)y.key()]["inputsRxed"][(std::string)x.key()] = 0;
            //std::cout << "x.key is " << x.key() << ", and y.key is " << y.key() << '\n';

            m_vectorOfServiceInputs.push_back(0);             // for now, just create vector entries for the inputs, so that if they arrive out of order, we can insert at any index location
          }
        }
      }
      //std::cout << "ServiceB dagServTracker data structure: " << std::setw(2) << m_dagServTracker << '\n';

      //std::cout << "Creating data for name: " << m_nameAndDigest << std::endl;  // m_name doesn't have the sha256 digest, so it doesn't match the original interest!
                                                                                // We use m_nameAndDigest to store the old name with the digest.
      m_extracted = true;
    }

    // IF we received a data request interest (ex: /service1/dataRequest/0/sensor), then generate the interest
    //else, continue below since it is a regular interest for the service itself
    ndn::Name nameAndDigest = interest.getName();  // store the name with digest
    std::string nameUri = nameAndDigest.getSubName(2,1).toUri(); // extract 1 component starting from component 2, and then convert to Uri string
    //std::cout << "  NAME COMPONENT 1: " << nameUri << std::endl;
    if (nameUri == "/dataRequest")
    {
      //generate interest for sensor
      std::string requestNameUri = nameAndDigest.getSubName(3,2).toUri(); // extract 2 components starting from component 3, and then convert to Uri string
      requestNameUri = "/serviceOrchestration/data" + requestNameUri + m_nameUri; // ask for requestNameUri data, and let the orchestrator know who it's coming from (so it can me marked as txed when it responds)
      //std::cout << "Interest was for dataRequest, thus generating interest for " << requestNameUri << std::endl;

      // generate the interest for this input
      auto dagParameterFromInterest = interest.getApplicationParameters();
      std::string dagString = std::string(reinterpret_cast<const char*>(dagParameterFromInterest.value()), dagParameterFromInterest.value_size());
      sendInterest(requestNameUri, dagString);
    }

    else
    {

      m_nameAndDigest = interest.getName();   // store the name with digest so that we can later generate the data packet with the same name/digest!
                                              // TODO: this has issues - we cannot use the same service in more than one location in the DAG workflow!
                                              // for this, we would need to be able to store and retrieve unique interests and their digest (perhaps using a fully hierarchical name?)
                                      // right now, this application only has one m_nameAndDigest private variable, and thus can only "store" one service instance.
                                      // we could turn that variable into a list of ndn::Name variables, and add to the list for each instance of the service?

      // check to see if we have already ran this service with the included DAG. If so, just respond with the results.
      // OR we can let the content store caching deal with responding
      if (m_done == true)
      {
        //std::cout << "    ServiceB: We already ran this service before. Responding with internally stored result!" << std::endl;
        // send stored result
        // Create new Data packet
        auto new_data = std::make_shared<Data>();
        new_data->setName(m_nameAndDigest);
        new_data->setFreshnessPeriod(9_s);
        unsigned char myBuffer[1024];
        // write to the buffer
        myBuffer[0] = m_serviceOutput;
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
        //std::cout << "<< D: " << *new_data << std::endl;
        m_face.put(*new_data);

        return;
      }



      // check which data inputs have not yet been received! Technically, the orchestrator should have already sent us all of them before genreating the main interest for service
      // generate all the interests for required inputs
      for (auto& serviceInput : m_dagServTracker[(std::string)m_nameUri]["inputsRxed"].items())
      {
        if (serviceInput.value() == 0)
        {
          //std::cout << "    ServiceB: ERROR! We should have already received this input, but somehow haven't: " << serviceInput.key() << std::endl;
          // generate the interest for this input
          std::string dagString = m_dagObject.dump();
          sendInterest(serviceInput.key(), dagString);
        }
      }

     

      //TODO: if the service doesn't need any inputs, we should run the service and respond with the data packet right from here.
      // with the RPA DAG, this doesn't apply, but we could have a workflow with services that don't require any input (no other interests need to be generated here).
    }

   
  }





private:
  void
  onData(const Interest&, const Data& data)
  {
    //std::cout << "Received Data: " << data << std::endl;
    //std::cout << "Data Content: " << data.getContent().value() << std::endl;


    std::string rxedDataName;

    // we need to make sure we check the first two parts of the name on the incomming data packets from the orchestrator
    //        for example: /interCACHE/serviceOrchestration/data/0/sensor/service1
    //        if the name starts with serviceOrcehstration/data, then we must treat them differently than a regular data packet
    ndn::Name nameAndDigest = (data.getName()).getPrefix(-1); // remove the last component of the name (the parameter digest) so we have just the raw name
    std::string firstTwo = nameAndDigest.getSubName(1,2).toUri(); // extract 2 components starting from component 1, and then convert to Uri string

    std::string inputNumString;
    std::string requestedService;
    std::string requestorService;
    char inputNum = -2; // just initialize to negative numeber that is not -1. It will be compared below, and if it is still -2, something is not working properly
    if (firstTwo == "/serviceOrchestration/data")
    {
      inputNumString   = nameAndDigest.getSubName(3,1).toUri(); // extract 1 components starting from component 3, and then convert to Uri string
      requestedService = nameAndDigest.getSubName(4,1).toUri(); // extract 1 components starting from component 4, and then convert to Uri string
      requestorService = nameAndDigest.getSubName(5,1).toUri(); // extract 1 components starting from component 5, and then convert to Uri string
      inputNumString = inputNumString.erase(0,1); // remove the "/" at the beginning of the Uri Name, to leave just the number (still as a string)
      inputNum = stoi(inputNumString);
      //std::cout << "Service received data for: " << firstTwo << ", requested service name: " << requestedService << ", stored at index " << inputNumString << ", by requestor: " << requestorService << std::endl;
      rxedDataName = requestedService;
    }

    else
    {
      rxedDataName = (data.getName()).getPrefix(-1).toUri(); // remove the last component of the name (the parameter digest) so we have just the raw name, and convert to Uri string
    }

    // TODO: this is a HACK. I need a better way to get to the first byte of the content. Right now, I'm just incrementing the pointer past the TLV type, and size.
    // and then getting to the first byte (which is all I'm using for data)
    uint8_t *pServiceInput = 0;
    //pServiceInput = (uint8_t *)(m_mapOfRxedBlocks.back().data());
    pServiceInput = (uint8_t *)(data.getContent().data()); // this points to the first byte, which is the TLV-TYPE (21 for data packet content)
    pServiceInput++;  // now this points to the second byte, containing 253 (0xFD), meaning size (1024) is expressed with 2 octets
    pServiceInput++;  // now this points to the first size octet
    pServiceInput++;  // now this points to the second size octet
    pServiceInput++;  // now we are pointing at the first byte of the true content
    //m_mapOfServiceInputs[rxedDataName] = (*pServiceInput);

    // we keep track of which input is for which interest that was sent out. Data packets may arrive in different order than how interests were sent out.
    // just read the index from the dagObject JSON structure
    char index = -1;
    for (auto& x : m_dagObject["dag"].items())
    {
      //std::cout << "  Evaluating source service " << (std::string)x.key() << '\n';
      if (x.key() == rxedDataName)
      {
        //std::cout << "  Found rxedDataName in dagObject! Looking for feed service now..." << '\n';
        for (auto& y : m_dagObject["dag"][x.key()].items())
        {
          //std::cout << "  Evaluating feed service " << (std::string)y.key() << '\n';
          if (y.key() == m_nameUri)
          {
            //std::cout << "  HIT, y.key(): " << y.key() << ", y.value(): " << y.value() << '\n';
            index = y.value().template get<char>();
          }
        }
      }
    }
    if (index != inputNum)
    {
      std::cout << "  ServiceB ERROR!! index inputs don't match! Something went wrong!!" << '\n';
      std::cout << "  Received index " << inputNumString << ", but dagOrchTracker has index " << std::to_string(index) << '\n';
    }
    if (index < 0)
    {
      std::cout << "  ServiceB ERROR!! index for m_vectorOfServiceInputs cannot be negative! Something went wrong!!" << '\n';
    }
    else
    {
      m_vectorOfServiceInputs[index] = (*pServiceInput);
    }

    // mark this input as having been received
    m_dagServTracker[m_nameUri]["inputsRxed"][rxedDataName] = 1;

    // we have to check if we have received all necessary inputs for this instance of the hosted service!
    //      if so, run the service below and generate new data packet to go downstream.
    //      otherwise, just wait for the other inputs.
    unsigned char allInputsReceived = 1;
    for (auto& serviceInput : m_dagServTracker[m_nameUri]["inputsRxed"].items())
    {
      if (serviceInput.value() == 0)
      {
        allInputsReceived = 0;
        break;
      }
    }
    if (allInputsReceived == 1)
    {
      //"RUN" the service, and create a new data packet to respond downstream
      //std::cout << "Running service " << m_service << std::endl;

      // run operation. First we need to figure out what service this is, so we know the operation. This screams to be a function pointer! For now just use if's

      // TODO: we should use function pointers here, and have each service be a function defined in a separate file. Figure out how to deal with potentially different num of inputs.

      if (m_service.ndn::Name::toUri() == "/service1"){
        m_serviceOutput = (m_vectorOfServiceInputs[0])*2;
      }
      if (m_service.ndn::Name::toUri() == "/service2"){
        m_serviceOutput = (m_vectorOfServiceInputs[0])+1;
      }
      if (m_service.ndn::Name::toUri() == "/service3"){
        m_serviceOutput = (m_vectorOfServiceInputs[0])+7;
      }
      if (m_service.ndn::Name::toUri() == "/service4"){
        m_serviceOutput = (m_vectorOfServiceInputs[0])*3 + (m_vectorOfServiceInputs[1])*4;
      }
      if (m_service.ndn::Name::toUri() == "/service5"){
        m_serviceOutput = (m_vectorOfServiceInputs[0])*2;
      }
      if (m_service.ndn::Name::toUri() == "/service6"){
        m_serviceOutput = (m_vectorOfServiceInputs[0])+1;
      }
      if (m_service.ndn::Name::toUri() == "/service7"){
        m_serviceOutput = (m_vectorOfServiceInputs[0])+7;
      }
      if (m_service.ndn::Name::toUri() == "/service8"){
        m_serviceOutput = (m_vectorOfServiceInputs[0])*1 + (m_vectorOfServiceInputs[1])*1;
      }
      if ((m_service.ndn::Name::toUri() == "/serviceL1") ||
          (m_service.ndn::Name::toUri() == "/serviceL2") ||
          (m_service.ndn::Name::toUri() == "/serviceL3") ||
          (m_service.ndn::Name::toUri() == "/serviceL4") ||
          (m_service.ndn::Name::toUri() == "/serviceL5") ||
          (m_service.ndn::Name::toUri() == "/serviceL6") ||
          (m_service.ndn::Name::toUri() == "/serviceL7") ||
          (m_service.ndn::Name::toUri() == "/serviceL8") ||
          (m_service.ndn::Name::toUri() == "/serviceL9") ||
          (m_service.ndn::Name::toUri() == "/serviceL10") ||
          (m_service.ndn::Name::toUri() == "/serviceL11") ||
          (m_service.ndn::Name::toUri() == "/serviceL12") ||
          (m_service.ndn::Name::toUri() == "/serviceL13") ||
          (m_service.ndn::Name::toUri() == "/serviceL14") ||
          (m_service.ndn::Name::toUri() == "/serviceL15") ||
          (m_service.ndn::Name::toUri() == "/serviceL16") ||
          (m_service.ndn::Name::toUri() == "/serviceL17") ||
          (m_service.ndn::Name::toUri() == "/serviceL18") ||
          (m_service.ndn::Name::toUri() == "/serviceL19") ||
          (m_service.ndn::Name::toUri() == "/serviceL20")){
        m_serviceOutput = (m_vectorOfServiceInputs[0])+1;
      }
      if ((m_service.ndn::Name::toUri() == "/serviceP1") ||
          (m_service.ndn::Name::toUri() == "/serviceP2") ||
          (m_service.ndn::Name::toUri() == "/serviceP3") ||
          (m_service.ndn::Name::toUri() == "/serviceP4") ||
          (m_service.ndn::Name::toUri() == "/serviceP5") ||
          (m_service.ndn::Name::toUri() == "/serviceP6") ||
          (m_service.ndn::Name::toUri() == "/serviceP7") ||
          (m_service.ndn::Name::toUri() == "/serviceP8") ||
          (m_service.ndn::Name::toUri() == "/serviceP9") ||
          (m_service.ndn::Name::toUri() == "/serviceP10") ||
          (m_service.ndn::Name::toUri() == "/serviceP11") ||
          (m_service.ndn::Name::toUri() == "/serviceP12") ||
          (m_service.ndn::Name::toUri() == "/serviceP13") ||
          (m_service.ndn::Name::toUri() == "/serviceP14") ||
          (m_service.ndn::Name::toUri() == "/serviceP15") ||
          (m_service.ndn::Name::toUri() == "/serviceP16") ||
          (m_service.ndn::Name::toUri() == "/serviceP17") ||
          (m_service.ndn::Name::toUri() == "/serviceP18") ||
          (m_service.ndn::Name::toUri() == "/serviceP19") ||
          (m_service.ndn::Name::toUri() == "/serviceP20")){
        m_serviceOutput = (m_vectorOfServiceInputs[0])+1;
      }
      if (m_service.ndn::Name::toUri() == "/serviceP21"){
        m_serviceOutput =
              (m_vectorOfServiceInputs[0])+
              (m_vectorOfServiceInputs[1])+
              (m_vectorOfServiceInputs[2])+
              (m_vectorOfServiceInputs[3])+
              (m_vectorOfServiceInputs[4])+
              (m_vectorOfServiceInputs[5])+
              (m_vectorOfServiceInputs[6])+
              (m_vectorOfServiceInputs[7])+
              (m_vectorOfServiceInputs[8])+
              (m_vectorOfServiceInputs[9])+
              (m_vectorOfServiceInputs[10])+
              (m_vectorOfServiceInputs[11])+
              (m_vectorOfServiceInputs[12])+
              (m_vectorOfServiceInputs[13])+
              (m_vectorOfServiceInputs[14])+
              (m_vectorOfServiceInputs[15])+
              (m_vectorOfServiceInputs[16])+
              (m_vectorOfServiceInputs[17])+
              (m_vectorOfServiceInputs[18])+
              (m_vectorOfServiceInputs[19]);
      }
      if ((m_service.ndn::Name::toUri() == "/serviceP22") ||
          (m_service.ndn::Name::toUri() == "/serviceP23") ||
          (m_service.ndn::Name::toUri() == "/serviceR1")){
        m_serviceOutput =
            (m_vectorOfServiceInputs[0])+
            (m_vectorOfServiceInputs[1])+
            (m_vectorOfServiceInputs[2]);
      }
      
      // we stored the result so we can respond later when the main service interest comes in!!

      //std::cout << "Service " << m_service.ndn::Name::toUri() << " has output: " << (int)m_serviceOutput << std::endl;
    
      m_done = true;

  /*  we no longer respond here. We only respond when the main interest for the service comes in.
      std::cout << "Creating data for name: " << m_nameAndDigest << std::endl;  // m_name doesn't have the sha256 digest, so it doesn't match the original interest!
                                                                    // We use m_nameAndDigest to store the old name with the digest.




      myBuffer[0] = m_serviceOutput;
      // in order to "host" the data locally, we must store it, and set a flag that is checked at "onInterest" above
      // This is a one time deal. Assumes data will be available and fresh from now on.
      // OR we can just let the content store deal with storing results
      // so now, we do the same for the copy that we store in m_data as we did for new_data above
      m_done = true;
      //m_data.ndn::setName(m_nameAndDigest);
      //m_data.setContent(myBuffer, 1024);
  */
    }
    //else
    //{
      //std::cout << "    Even though we received data packet, we are still waiting for more inputs!" << std::endl;
    //}


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

  ndn::Name m_name;
  std::string m_nameUri;
  ndn::Name m_nameAndDigest;
  ndn::Name m_service;
  bool m_done;
  bool m_extracted;
  unsigned char m_serviceOutput;
  json m_dagServTracker;
  json m_dagObject;
  std::vector <unsigned char> m_vectorOfServiceInputs;
};

} // namespace examples
} // namespace ndn

int
main(int argc, char** argv)
{
  try {
    ndn::examples::ServiceB serviceB;
    serviceB.run(argv[1], argv[2]);
    return 0;
  }
  catch (const std::exception& e) {
    std::cerr << "ERROR: " << e.what() << std::endl;
    return 1;
  }
}
