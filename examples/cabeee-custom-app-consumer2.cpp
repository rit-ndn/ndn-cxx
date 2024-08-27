/* -*- Mode:C++; c-file-style:"gnu"; indent-tabs-mode:nil; -*- */
/*
 * Copyright (c) 2013-2022 Regents of the University of California.
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
//#include <ndn-cxx/security/validator-config.hpp>

#include <iostream>

#include <fstream>
#include <nlohmann/json.hpp>
using json = nlohmann::json;
#include <ndn-cxx/util/io.hpp>

#include <array>

#include <ctime>
#include <chrono>


// Enclosing code in ndn simplifies coding (can also use `using namespace ndn`)
namespace ndn {
// Additional nested namespaces should be used to prevent/limit name conflicts
namespace examples {

class Consumer2
{
public:
  //Consumer2()
  //{
    //m_validator.load("/home/cabeee/mini-ndn/dl/ndn-cxx/examples/cabeee-trust-schema.conf");
    //m_validator.load("/opt/ndn/cabeee-trust-schema.conf");
  //}

  void
  run(char* PREFIX, char* workflowFile, char* orchestrationType)
  {

    startTime = std::chrono::steady_clock::now();

    m_dagPath = workflowFile;
    std::cout << "Consumer is using Workflow File: " << m_dagPath << std::endl;
    std::ifstream f(m_dagPath);
    json dagObject = json::parse(f);

    // here we generate just the first interest(s) according to the workflow
    // to do this, we must discover which services in the DAG are "sink" services (services which feed the end consumer)

    //std::cout << "Looking for sink service!" << std::endl;
    std::string sinkService;
    for (auto& x : dagObject["dag"].items())
    {
      for (auto& y : dagObject["dag"][x.key()].items())
      {
        if (y.key() == "/consumer2")
        {
          sinkService = x.key();
        }
      }
    }
    //std::cout << "Sink service is: " << sinkService << std::endl;


    std::string prefixString(PREFIX);
    prefixString.append("/tempName");
    Name interestName(prefixString);
    interestName.appendVersion();
    Interest interest(interestName);
    //interest.setMustBeFresh(true); // forcing fresh data allows us to run "non-caching" scenarios back-to-back (waiting for data packet lifetime to expire), and we won't be utilizing cached packets from a previous run.
    interest.setMustBeFresh(false);
    interest.setInterestLifetime(6_s); // The default is 4 seconds

    m_orchestrate = atoi(orchestrationType);
    if (m_orchestrate == 0) {
      dagObject["head"] = sinkService;
      interest.setName(PREFIX + sinkService);
      std::cout << "Interest name is: " << interest.getName() << std::endl;

      bool consumerFound = false;
      // now we remove the entry that has the sinkService feeding the consumer. It is not needed, and can't be in the dag if we want caching of intermediate results to work.
      for (auto& x : dagObject["dag"].items())
      {
        //std::cout << "Checking x.key: " << (std::string)x.key() << '\n';
        for (auto& y : dagObject["dag"][x.key()].items())
        {
          //std::cout << "Checking y.key: " << (std::string)y.key() << '\n';
          //if (y.key() == m_name.ndn::Name::toUri())
          if (y.key() == "/consumer2")
          {
            dagObject["dag"].erase(x.key());
            consumerFound = true;
            break;
          }
        }
        if (consumerFound == true)
          break;
      }
    }
    else if (m_orchestrate == 1){ // orchestration method A
      dagObject["head"] = "/serviceOrchestration";
      prefixString = PREFIX;
      prefixString.append("/serviceOrchestration");
      interest.setName(prefixString);
    }
    else if (m_orchestrate == 2){ // orchestration method B
      dagObject["head"] = "/serviceOrchestration/dag";
      prefixString = PREFIX;
      prefixString.append("/serviceOrchestration/dag");
      interest.setName(prefixString);
    }
    else
    {
      std::cout << "ERROR, this should not happen. m_orchestrate value set out of bounds!" << std::endl;
      return;
    }


    // add dagStringParameter as custom ApplicationParameter to interest packet

    std::string dagString = dagObject.dump();
    //std::cout << "dagString: " << dagString << std::endl;

    std::shared_ptr<Buffer> dagApplicationParameters;
    std::istringstream is(dagString);
    dagApplicationParameters = io::loadBuffer(is, io::NO_ENCODING);
    interest.setApplicationParameters(dagApplicationParameters);



    //std::cout << "Sending Interest " << interest << std::endl;

    //bool dagParameterDigestValid = interest.isParametersDigestValid();
    //std::cout << "Fwd: Interest parameter digest is valid: " << dagParameterDigestValid << std::endl;
    //bool dagParameterPresent = interest.hasApplicationParameters();
    //std::cout << "Fwd: Interest parameters presesnt: " << dagParameterPresent << std::endl;
  
    auto dagParameterFromInterest = interest.getApplicationParameters();
    //std::cout << "dagParameterFromInterest: " << dagParameterFromInterest << std::endl;
    std::string myDagString = std::string(reinterpret_cast<const char*>(dagParameterFromInterest.value()), dagParameterFromInterest.value_size());
    //std::cout << "myDagString: " << std::setw(2) << myDagString << std::endl;
    json m_dagObject;
    m_dagObject = json::parse(myDagString);
    //std::cout << "Full DAG being sent: " << std::setw(2) << m_dagObject << std::endl;


    m_face.expressInterest(interest,
                           std::bind(&Consumer2::onData, this,  _1, _2),
                           std::bind(&Consumer2::onNack, this, _1, _2),
                           std::bind(&Consumer2::onTimeout, this, _1));

    // processEvents will block until the requested data is received or a timeout occurs
    m_face.processEvents();
  }

private:
  void
  onData(const Interest&, const Data& data)
  {
    //std::cout << "Received Data: " << data << std::endl;
    //std::cout << "Data Content: " << data.getContent().value() << std::endl;

    std::cout << "\n\n      CONSUMER2: DATA received for name " << data.getName() << std::endl << "\n\n";
    ndn::Block myRxedBlock = data.getContent();
    //std::cout << "\nCONSUMER2: result = " << myRxedBlock << std::endl << "\n\n";

    uint8_t *pContent = (uint8_t *)(myRxedBlock.data()); // this points to the first byte, which is the TLV-TYPE (21 for data packet contet)
    pContent++;  // now this points to the second byte, containing 253 (0xFD), meaning size (1024) is expressed with 2 octets
    pContent++;  // now this points to the first size octet
    pContent++;  // now this points to the second size octet
    pContent++;  // now we are pointing at the first byte of the true content
    std::cout << "\n  The final answer is: " <<  (int)(*pContent) << std::endl << "\n\n";
  

    /*
    m_validator.validate(data,
                         [] (const Data&) {
                           std::cout << "Data conforms to trust schema" << std::endl;
                         },
                         [] (const Data&, const security::ValidationError& error) {
                           std::cout << "Error authenticating data: " << error << std::endl;
                         });
    */

    endTime = std::chrono::steady_clock::now();
    std::chrono::steady_clock::duration serviceLatency = endTime - startTime;
    double nSeconds = double(serviceLatency.count()) * std::chrono::steady_clock::period::num / std::chrono::steady_clock::period::den;
    std::cout << "\n  Service Latency: " <<  nSeconds << " seconds." << std::endl;
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

private:
  Face m_face;
  //ValidatorConfig m_validator{m_face};
  uint16_t m_orchestrate;
  std::string m_dagPath;
  std::chrono::steady_clock::time_point startTime;
  std::chrono::steady_clock::time_point endTime;
};

} // namespace examples
} // namespace ndn

int
main(int argc, char** argv)
{
  try {
    ndn::examples::Consumer2 consumer2;
    consumer2.run(argv[1], argv[2], argv[3]);
    return 0;
  }
  catch (const std::exception& e) {
    std::cerr << "ERROR: " << e.what() << std::endl;
    return 1;
  }
}
