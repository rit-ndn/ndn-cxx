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

class OrchestratorA_reset
{
public:
  //OrchestratorA_reset()
  //{
    //m_validator.load("/home/cabeee/mini-ndn/dl/ndn-cxx/examples/cabeee-trust-schema.conf");
  //}

  void
  run(char* PREFIX, char* servicePrefix)
  {
    std::string prefixString(PREFIX);
    prefixString.append(servicePrefix);
    Name interestName(prefixString);
    Interest interest(interestName);
    interest.setMustBeFresh(true); // we don't want cached results, we're not interested in data results at all. ie: the interest MUST reach the producer (the ochestrator)
    interest.setInterestLifetime(6_s); // The default is 4 seconds
    std::cout << "Sending Interest " << interest << std::endl;

    m_face.expressInterest(interest,
                           std::bind(&OrchestratorA_reset::onData, this,  _1, _2),
                           std::bind(&OrchestratorA_reset::onNack, this, _1, _2),
                           std::bind(&OrchestratorA_reset::onTimeout, this, _1));

    // processEvents will block until the requested data is received or a timeout occurs
    m_face.processEvents();
  }


private:
  void
  onData(const Interest&, const Data& data)
  {
    //std::cout << "Received Data: " << data << std::endl;
    //std::cout << "Data Content: " << data.getContent().value() << std::endl;

    std::cout << "\n\n      OrchestratorA_reset: DATA received for name " << data.getName() << std::endl << "\n\n";
    ndn::Block myRxedBlock = data.getContent();
    //std::cout << "\OrchestratorA_reset: result = " << myRxedBlock << std::endl << "\n\n";

    /*
    m_validator.validate(data,
                         [] (const Data&) {
                           std::cout << "Data conforms to trust schema" << std::endl;
                         },
                         [] (const Data&, const security::ValidationError& error) {
                           std::cout << "Error authenticating data: " << error << std::endl;
                         });
    */
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
};

} // namespace examples
} // namespace ndn

int
main(int argc, char** argv)
{
  try {
    ndn::examples::OrchestratorA_reset orchestratorA_reset;
    orchestratorA_reset.run(argv[1], argv[2]);
    return 0;
  }
  catch (const std::exception& e) {
    std::cerr << "ERROR: " << e.what() << std::endl;
    return 1;
  }
}
