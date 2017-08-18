/* -*- Mode:C++; c-file-style:"gnu"; indent-tabs-mode:nil; -*- */
/*
 * Copyright (c) 2013-2017 Regents of the University of California.
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

#include "validation-policy-config.hpp"
#include "validator.hpp"
#include "../../util/io.hpp"

#include <boost/algorithm/string.hpp>
#include <boost/filesystem.hpp>
#include <boost/lexical_cast.hpp>
#include <boost/property_tree/info_parser.hpp>

namespace ndn {
namespace security {
namespace v2 {
namespace validator_config {

ValidationPolicyConfig::ValidationPolicyConfig()
  : m_shouldBypass(false)
  , m_isConfigured(false)
{
}

void
ValidationPolicyConfig::load(const std::string& filename)
{
  std::ifstream inputFile;
  inputFile.open(filename.c_str());
  if (!inputFile.good() || !inputFile.is_open()) {
    std::string msg = "Failed to read configuration file: ";
    msg += filename;
    BOOST_THROW_EXCEPTION(Error(msg));
  }
  load(inputFile, filename);
  inputFile.close();
}

void
ValidationPolicyConfig::load(const std::string& input, const std::string& filename)
{
  std::istringstream inputStream(input);
  load(inputStream, filename);
}

void
ValidationPolicyConfig::load(std::istream& input, const std::string& filename)
{
  ConfigSection tree;
  try {
    boost::property_tree::read_info(input, tree);
  }
  catch (const boost::property_tree::info_parser_error& error) {
    std::stringstream msg;
    msg << "Failed to parse configuration file";
    msg << " " << filename;
    msg << " " << error.message() << " line " << error.line();
    BOOST_THROW_EXCEPTION(Error(msg.str()));
  }

  load(tree, filename);
}

void
ValidationPolicyConfig::load(const ConfigSection& configSection,
                             const std::string& filename)
{
  if (m_isConfigured) {
    BOOST_THROW_EXCEPTION(std::logic_error("ValidationPolicyConfig can be configured only once"));
  }
  m_isConfigured = true;

  BOOST_ASSERT(!filename.empty());

  if (configSection.begin() == configSection.end()) {
    std::string msg = "Error processing configuration file";
    msg += ": ";
    msg += filename;
    msg += " no data";
    BOOST_THROW_EXCEPTION(Error(msg));
  }

  for (const auto& subSection : configSection) {
    const std::string& sectionName = subSection.first;
    const ConfigSection& section = subSection.second;

    if (boost::iequals(sectionName, "rule")) {
      auto rule = Rule::create(section, filename);
      if (rule->getPktType() == tlv::Data) {
        m_dataRules.push_back(std::move(rule));
      }
      else if (rule->getPktType() == tlv::Interest) {
        m_interestRules.push_back(std::move(rule));
      }
    }
    else if (boost::iequals(sectionName, "trust-anchor")) {
      processConfigTrustAnchor(section, filename);
    }
    else {
      std::string msg = "Error processing configuration file";
      msg += " ";
      msg += filename;
      msg += " unrecognized section: " + sectionName;
      BOOST_THROW_EXCEPTION(Error(msg));
    }
  }
}

void
ValidationPolicyConfig::processConfigTrustAnchor(const ConfigSection& configSection, const std::string& filename)
{
  using namespace boost::filesystem;

  ConfigSection::const_iterator propertyIt = configSection.begin();

  // Get trust-anchor.type
  if (propertyIt == configSection.end() || !boost::iequals(propertyIt->first, "type")) {
    BOOST_THROW_EXCEPTION(Error("Expecting <trust-anchor.type>"));
  }

  std::string type = propertyIt->second.data();
  propertyIt++;

  if (boost::iequals(type, "file")) {
    // Get trust-anchor.file
    if (propertyIt == configSection.end() || !boost::iequals(propertyIt->first, "file-name")) {
      BOOST_THROW_EXCEPTION(Error("Expecting <trust-anchor.file-name>"));
    }

    std::string file = propertyIt->second.data();
    propertyIt++;

    time::nanoseconds refresh = getRefreshPeriod(propertyIt, configSection.end());
    if (propertyIt != configSection.end()) {
      BOOST_THROW_EXCEPTION(Error("Expect the end of trust-anchor!"));
    }

    m_validator->loadAnchor(filename, absolute(file, path(filename).parent_path()).string(),
                            refresh, false);
    return;
  }
  else if (boost::iequals(type, "base64")) {
    // Get trust-anchor.base64-string
    if (propertyIt == configSection.end() || !boost::iequals(propertyIt->first, "base64-string"))
      BOOST_THROW_EXCEPTION(Error("Expecting <trust-anchor.base64-string>"));

    std::stringstream ss(propertyIt->second.data());
    propertyIt++;

    // Check other stuff
    if (propertyIt != configSection.end())
      BOOST_THROW_EXCEPTION(Error("Expecting the end of trust-anchor"));

    auto idCert = io::load<Certificate>(ss);
    if (idCert != nullptr) {
      m_validator->loadAnchor("", std::move(*idCert));
    }
    else {
      BOOST_THROW_EXCEPTION(Error("Cannot decode certificate from base64-string"));
    }

    return;
  }
  else if (boost::iequals(type, "dir")) {
    if (propertyIt == configSection.end() || !boost::iequals(propertyIt->first, "dir"))
      BOOST_THROW_EXCEPTION(Error("Expect <trust-anchor.dir>"));

    std::string dirString(propertyIt->second.data());
    propertyIt++;

    time::nanoseconds refresh = getRefreshPeriod(propertyIt, configSection.end());
    if (propertyIt != configSection.end()) {
      BOOST_THROW_EXCEPTION(Error("Expecting the end of trust-anchor"));
    }

    path dirPath = absolute(dirString, path(filename).parent_path());
    m_validator->loadAnchor(dirString, dirPath.string(), refresh, true);
    return;
  }
  else if (boost::iequals(type, "any")) {
    m_shouldBypass = true;
  }
  else {
    BOOST_THROW_EXCEPTION(Error("Unsupported trust-anchor.type: " + type));
  }
}

time::nanoseconds
ValidationPolicyConfig::getRefreshPeriod(ConfigSection::const_iterator& it,
                                         const ConfigSection::const_iterator& end)
{
  time::nanoseconds refresh = time::nanoseconds::max();
  if (it == end) {
    return refresh;
  }

  if (!boost::iequals(it->first, "refresh")) {
    BOOST_THROW_EXCEPTION(Error("Expecting <trust-anchor.refresh>"));
  }

  std::string inputString = it->second.data();
  ++it;

  char unit = inputString[inputString.size() - 1];
  std::string refreshString = inputString.substr(0, inputString.size() - 1);

  uint32_t refreshPeriod = 0;

  try {
    refreshPeriod = boost::lexical_cast<uint32_t>(refreshString);
  }
  catch (const boost::bad_lexical_cast&) {
    BOOST_THROW_EXCEPTION(Error("Bad number: " + refreshString));
  }

  if (refreshPeriod == 0) {
    return getDefaultRefreshPeriod();
  }

  switch (unit) {
    case 'h':
      return time::duration_cast<time::nanoseconds>(time::hours(refreshPeriod));
    case 'm':
      return time::duration_cast<time::nanoseconds>(time::minutes(refreshPeriod));
    case 's':
      return time::duration_cast<time::nanoseconds>(time::seconds(refreshPeriod));
    default:
      BOOST_THROW_EXCEPTION(Error(std::string("Wrong time unit: ") + unit));
  }
}

time::nanoseconds
ValidationPolicyConfig::getDefaultRefreshPeriod()
{
  return time::duration_cast<time::nanoseconds>(time::seconds(3600));
}

void
ValidationPolicyConfig::checkPolicy(const Data& data, const shared_ptr<ValidationState>& state,
                                    const ValidationContinuation& continueValidation)
{
  BOOST_ASSERT_MSG(!hasInnerPolicy(), "ValidationPolicyConfig must be a terminal inner policy");

  if (m_shouldBypass) {
    return continueValidation(nullptr, state);
  }

  Name klName = getKeyLocatorName(data, *state);
  if (!state->getOutcome()) { // already failed
    return;
  }

  for (const auto& rule : m_dataRules) {
    if (rule->match(tlv::Data, data.getName())) {
      if (rule->check(tlv::Data, data.getName(), klName, state)) {
        return continueValidation(make_shared<CertificateRequest>(Interest(klName)), state);
      }
      // rule->check calls state->fail(...) if the check fails
      return;
    }
  }

  return state->fail({ValidationError::POLICY_ERROR, "No rule matched for data `" + data.getName().toUri() + "`"});
}

void
ValidationPolicyConfig::checkPolicy(const Interest& interest, const shared_ptr<ValidationState>& state,
                                    const ValidationContinuation& continueValidation)
{
  BOOST_ASSERT_MSG(!hasInnerPolicy(), "ValidationPolicyConfig must be a terminal inner policy");

  if (m_shouldBypass) {
    return continueValidation(nullptr, state);
  }

  Name klName = getKeyLocatorName(interest, *state);
  if (!state->getOutcome()) { // already failed
    return;
  }

  for (const auto& rule : m_interestRules) {
    if (rule->match(tlv::Interest, interest.getName())) {
      if (rule->check(tlv::Interest, interest.getName(), klName, state)) {
        return continueValidation(make_shared<CertificateRequest>(Interest(klName)), state);
      }
      // rule->check calls state->fail(...) if the check fails
      return;
    }
  }

  return state->fail({ValidationError::POLICY_ERROR, "No rule matched for interest `" + interest.getName().toUri() + "`"});
}

} // namespace validator_config
} // namespace v2
} // namespace security
} // namespace ndn