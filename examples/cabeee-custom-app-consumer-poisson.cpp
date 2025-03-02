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
#include <thread>

#include <ndn-cxx/util/random.hpp>
#include <ndn-cxx/util/scheduler.hpp>
#include <boost/asio/io_context.hpp>
#include <random>


// Enclosing code in ndn simplifies coding (can also use `using namespace ndn`)
namespace ndn {
// Additional nested namespaces should be used to prevent/limit name conflicts
namespace examples {

class Consumer
{
public:
  //Consumer()
  //{
    //m_validator.load("/home/cabeee/mini-ndn/dl/ndn-cxx/examples/cabeee-trust-schema.conf");
    //m_validator.load("/opt/ndn/cabeee-trust-schema.conf");
  //}

  void
  run(char* PREFIX, char* serviceName, char* workflowFile, char* orchestrationType, char* interestFrequency, char* numInterests)
  {
    m_PREFIX = PREFIX;
    m_service = serviceName;
    m_dagPath = workflowFile;
    m_orchestrate = atoi(orchestrationType);
    m_interestFrequency = atoi(interestFrequency);
    m_numInterests = atoi(numInterests);
    m_interestNum = 1;
    m_waitingForData = 0;

    std::cout << "Consumer (Poisson Process) starting to send interests!" << std::endl;
    //sendInterest();
    for (m_interestNum = 1; m_interestNum <= m_numInterests; m_interestNum++)
    {
      //int randomWait_ms = 1000/m_interestFrequency;
      double const exp_dist_mean = 1000.0 / m_interestFrequency;
      double const exp_dist_lambda = 1 / exp_dist_mean;
      std::random_device rd;
      std::exponential_distribution<> rng (exp_dist_lambda);
      std::mt19937 rnd_gen (rd ());
      int randomWait_ms = rng(rnd_gen);

      std::cout << "Consumer is waiting " << randomWait_ms << " milliseconds before sending next interest." << std::endl;

      //m_scheduler.schedule(ndn::time::milliseconds(randomWait_ms), [this] { sendInterest(); });
      //m_ioCtx.run(); // will block until all events finished or m_ioCtx.stop() is called
      //m_face.processEvents(); //processEvents will block until the requested data is received or a timeout occurs
      std::this_thread::sleep_for(std::chrono::milliseconds(randomWait_ms));
      sendInterest();
      while (m_waitingForData);
    }
    //m_ioCtx.run(); // m_ioCtx.run() will block until all events finished or m_ioCtx.stop() is called
    m_face.processEvents(); // processEvents will block until the requested data is received or a timeout occurs
  }



private:
  void
  sendInterest()
  {


    //if(m_interestNum < m_numInterests)
    if(true)
    {
      m_waitingForData = 1;
      std::cout << "Preparing Interest " << m_interestNum << "/" << m_numInterests << "!" << std::endl;
      startTime = std::chrono::steady_clock::now();
  
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
          if (y.key() == "/consumer")
          {
            sinkService = x.key();
          }
        }
      }
      //std::cout << "Sink service is: " << sinkService << std::endl;
  
  
      std::string prefixString(m_PREFIX);
      prefixString.append("/tempName");
      Name interestName(prefixString);
      interestName.appendVersion();
      Interest interest(interestName);
      interest.setMustBeFresh(true); // forcing fresh data allows us to run "non-caching" scenarios back-to-back (waiting for data packet lifetime to expire), and we won't be utilizing cached packets from a previous run.
      interest.setInterestLifetime(6_s); // The default is 4 seconds
  
      if (m_orchestrate == 0) {
        dagObject["head"] = sinkService;
        interest.setName(m_PREFIX + sinkService);
        std::cout << "Interest name is: " << interest.getName() << std::endl;
  
        bool consumerFound = false;
        // now we remove the entry that has the sinkService feeding the consumer. It is not needed, and can't be in the dag if we want caching of intermediate results to work.
        for (auto& x : dagObject["dag"].items())
        {
          //std::cout << "Checking x.key: " << (std::string)x.key() << '\n';
          for (auto& y : dagObject["dag"][x.key()].items())
          {
            //std::cout << "Checking y.key: " << (std::string)y.key() << '\n';
            //if (y.key() == m_service)
            if (y.key() == "/consumer")
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
        prefixString = m_PREFIX;
        prefixString.append("/serviceOrchestration");
        interest.setName(prefixString);
      }
      else if (m_orchestrate == 2){ // orchestration method B
        dagObject["head"] = "/serviceOrchestration/dag";
        prefixString = m_PREFIX;
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
  
      std::cout << "Sending Interest " << m_interestNum << "/" << m_numInterests << ": " << interest << std::endl;


  
      m_face.expressInterest(interest,
                             std::bind(&Consumer::onData, this,  _1, _2),
                             std::bind(&Consumer::onNack, this, _1, _2),
                             std::bind(&Consumer::onTimeout, this, _1));
  
      m_face.processEvents(); // processEvents will block until the requested data is received or a timeout occurs
/*
     //int randomWait = (random::generateWord32() % (max - min)) + min;
      m_interestNum++;
      int randomWait_ms = 1000/m_interestFrequency;
      std::cout << "waiting before sending next Interest (ms): " << randomWait_ms << std::endl;
      m_scheduler.schedule(ndn::time::milliseconds(randomWait_ms), [this] { sendInterest(); });
      std::cout << "blocking inside sendInterest() waiting for all events to finish." << std::endl;
      //m_ioCtx.run() will block until all events finished or m_ioCtx.stop() is called
      //processEvents will block until the requested data is received or a timeout occurs
      m_face.processEvents();
      std::cout << "blocking inside sendInterest() while waiting for all events to finish (m_ioCtx) has passed." << std::endl;
*/
    }
  }

private:
  void
  onData(const Interest&, const Data& data)
  {
    //std::cout << "Received Data: " << data << std::endl;
    //std::cout << "Data Content: " << data.getContent().value() << std::endl;

    std::cout << "\n\n      CONSUMER: " << m_interestNum << "/" << m_numInterests << " DATA received for name " << data.getName() << std::endl << "\n\n";
    ndn::Block myRxedBlock = data.getContent();
    //std::cout << "\nCONSUMER: result = " << myRxedBlock << std::endl << "\n\n";

    uint8_t *pContent = (uint8_t *)(myRxedBlock.data()); // this points to the first byte, which is the TLV-TYPE (21 for data packet contet)
    pContent++;  // now this points to the second byte, containing 253 (0xFD), meaning size (1024) is expressed with 2 octets
    pContent++;  // now this points to the first size octet
    pContent++;  // now this points to the second size octet
    pContent++;  // now we are pointing at the first byte of the true content
    std::cout << "  Final answer for    " << m_service << " " << m_interestNum << "/" << m_numInterests << ": " <<  (int)(*pContent)  << std::endl;
 
    m_waitingForData = 0; 

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
  std::cout << "  Service Latency for " << m_service << " " << m_interestNum << "/" << m_numInterests << ": " <<  nSeconds << " seconds." << std::endl;
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
  // Explicitly create io_context object, which will be shared between Face and Scheduler
  //boost::asio::io_context m_ioCtx;
  //Face m_face{m_ioCtx};
  Face m_face;
  //ValidatorConfig m_validator{m_face};
  std::string m_service;
  uint16_t m_orchestrate;
  std::string m_dagPath;
  std::chrono::steady_clock::time_point startTime;
  std::chrono::steady_clock::time_point endTime;
  char* m_PREFIX;
  int m_interestFrequency;
  int m_numInterests;
  int m_interestNum;
  //Scheduler m_scheduler{m_ioCtx};
  char m_waitingForData;
};

} // namespace examples
} // namespace ndn

int
main(int argc, char** argv)
{
  try {
    ndn::examples::Consumer consumer;
    consumer.run(argv[1], argv[2], argv[3], argv[4], argv[5], argv[6]);
    return 0;
  }
  catch (const std::exception& e) {
    std::cerr << "ERROR: " << e.what() << std::endl;
    return 1;
  }
}
