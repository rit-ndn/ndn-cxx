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

class CsUpdater
{
public:
  //CsUpdater()
  //{
    //m_validator.load("/home/cabeee/mini-ndn/dl/ndn-cxx/examples/cabeee-trust-schema.conf");
    //m_validator.load("/opt/ndn/cabeee-trust-schema.conf");
  //}

  void
  run(char* PREFIX)
  {


    // listen to /PREFIX/csUpdate interest message from NFD. When received, set the interest filter to the name of the cached content (name comes in application parameter).

    m_PREFIX = PREFIX;
    std::string fullPrefix(PREFIX);
    fullPrefix.append("/csUpdate");
    std::cout << "CsUpdater listening to: " << fullPrefix << '\n';
    m_face.setInterestFilter(fullPrefix,
                             std::bind(&CsUpdater::onInterest, this, _2),
                             nullptr, // RegisterPrefixSuccessCallback is optional
                             std::bind(&CsUpdater::onRegisterFailed, this, _1, _2));

    auto cert = m_keyChain.getPib().getDefaultIdentity().getDefaultKey().getDefaultCertificate();
    m_certServeHandle = m_face.setInterestFilter(security::extractIdentityFromCertName(cert.getName()),
                                                 [this, cert] (auto&&...) {
                                                   m_face.put(cert);
                                                 },
                                                 std::bind(&CsUpdater::onRegisterFailed, this, _1, _2));
    m_face.processEvents();
  }



private:
  void
  onInterest(const Interest& interest)
  {
    //std::cout << ">> I: " << interest << std::endl;

    // decode the CS content name string contained in the application parameters, so we can register the name in RIB/FIB
    //extract custom parameter from interest packet

    std::cout << "CsUpdater received interest with name: " << interest.getName() << '\n';


    if(interest.getName().getPrefix(2).toUri() == "/nesco/csUpdate")
    {

      auto csParameterFromInterest = interest.getApplicationParameters();
      std::string csContentName = std::string(reinterpret_cast<const char*>(csParameterFromInterest.value()), csParameterFromInterest.value_size());

      std::cout << "CsUpdater setting interest filter for cached content name: " << csContentName << '\n';

      m_face.setInterestFilter(csContentName,
                              std::bind(&CsUpdater::onInterest, this, _2),
                              nullptr, // RegisterPrefixSuccessCallback is optional
                              std::bind(&CsUpdater::onRegisterFailed, this, _1, _2));


      std::cout << "CsUpdater face processing events..." << '\n';
      // we need to prevent this from blocking!
      m_face.processEvents(ndn::time::milliseconds(-1)); // If a negative timeout is specified, then processEvents will not block and will process only pending events.
    }

  }



private:
  void
  onData(const Interest&, const Data& data)
  {
    std::cout << "csUpdater application received data (it's not supposed to)." << std::endl;
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
  char* m_PREFIX;
  //ValidatorConfig m_validator{m_face};
  KeyChain m_keyChain;
  ScopedRegisteredPrefixHandle m_certServeHandle;
};

} // namespace examples
} // namespace ndn

int
main(int argc, char** argv)
{
  try {
    ndn::examples::CsUpdater csUpdater;
    csUpdater.run(argv[1]);
    return 0;
  }
  catch (const std::exception& e) {
    std::cerr << "ERROR: " << e.what() << std::endl;
    return 1;
  }
}
