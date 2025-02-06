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

#include <ndn-cxx/util/random.hpp>


// Enclosing code in ndn simplifies coding (can also use `using namespace ndn`)
namespace ndn {
// Additional nested namespaces should be used to prevent/limit name conflicts
namespace examples {

class Producer
{
public:
  void
  //run(char* PREFIX, char* servicePrefix)
  run(char* PREFIX, char* servicePrefix, char* freshnessPeriod_ms, char* uniformFreshness, char* minFreshness_ms, char* maxFreshness_ms)
  {
    std::string fullPrefix(PREFIX);
    fullPrefix.append(servicePrefix);
    std::cout << "Producer listening to: " << fullPrefix << '\n';
    m_face.setInterestFilter(fullPrefix,
                             std::bind(&Producer::onInterest, this, _2),
                             nullptr, // RegisterPrefixSuccessCallback is optional
                             std::bind(&Producer::onRegisterFailed, this, _1, _2));

    m_freshnessPeriod_ms = atoi(freshnessPeriod_ms);
    m_uniformFreshness = atoi(uniformFreshness);
    m_minFreshness_ms = atoi(minFreshness_ms);
    m_maxFreshness_ms = atoi(maxFreshness_ms);
    if (m_uniformFreshness == 1)
    {
      m_freshnessPeriod_ms = (random::generateWord32() % (m_maxFreshness_ms - m_minFreshness_ms)) + m_minFreshness_ms;
    }

    auto cert = m_keyChain.getPib().getDefaultIdentity().getDefaultKey().getDefaultCertificate();
    m_certServeHandle = m_face.setInterestFilter(security::extractIdentityFromCertName(cert.getName()),
                                                 [this, cert] (auto&&...) {
                                                   m_face.put(cert);
                                                 },
                                                 std::bind(&Producer::onRegisterFailed, this, _1, _2));
    m_face.processEvents();
  }

private:
  void
  onInterest(const Interest& interest)
  {
    //std::cout << ">> I: " << interest << std::endl;

    // Create Data packet
    auto data = std::make_shared<Data>();
    data->setName(interest.getName());
    if (m_uniformFreshness == 2)
    {
      m_freshnessPeriod_ms = (random::generateWord32() % (m_maxFreshness_ms - m_minFreshness_ms)) + m_minFreshness_ms;
    }
    data->setFreshnessPeriod(time::milliseconds(m_freshnessPeriod_ms));
    data->setFreshnessPeriod(9_s);


    unsigned char myBuffer[1024];
    // write to the buffer
    myBuffer[0] = 5;
    data->setContent(myBuffer);


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
    //m_keyChain.sign(*data);
    // m_keyChain.sign(*data, signingByIdentity(<identityName>));
    // m_keyChain.sign(*data, signingByKey(<keyName>));
    // m_keyChain.sign(*data, signingByCertificate(<certName>));
     m_keyChain.sign(*data, signingWithSha256());

    // Return Data packet to the requester
    //std::cout << "<< D: " << *data << std::endl;
    m_face.put(*data);
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
  KeyChain m_keyChain;
  ScopedRegisteredPrefixHandle m_certServeHandle;
  int m_freshnessPeriod_ms;
  int m_uniformFreshness;
  int m_minFreshness_ms;
  int m_maxFreshness_ms;
};

} // namespace examples
} // namespace ndn

int
main(int argc, char** argv)
{
  try {
    ndn::examples::Producer producer;
    //producer.run(argv[1], argv[2]);
    producer.run(argv[1], argv[2], argv[3], argv[4], argv[5], argv[6]); // prefix, name, freshness(ms), uniform, min, max
    return 0;
  }
  catch (const std::exception& e) {
    std::cerr << "ERROR: " << e.what() << std::endl;
    return 1;
  }
}
