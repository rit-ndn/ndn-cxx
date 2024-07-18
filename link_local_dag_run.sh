#! /bin/bash


#----- THIS ONLY NEEDS TO BE RUN ONCE --------------------
#cd ~/ndn/ndn-cxx
#./waf clean
#./waf
#sudo ./waf install
#nfd-start
#---------------------------------------------------------



username=cabeee

lenovoWiFiIP=192.168.20.143
jetsonNanoETHIP=192.168.20.145
rPi4WiFiIP=192.168.20.147
rPi3WiFiIP=192.168.20.151

lenovoETHMAC=D8:CB:8A:BC:A3:94
rPi4ETHMAC=d8:3a:dd:2e:c5:1f

lenovoETHinterface=eno1
rPi4ETHinterface=eth0

#clear


# to run <command> remotely:
#ssh <username>@<ip_address> "nohup <command> >/dev/null 2>/dev/null </dev/null &"
# or
#ssh <username>@<ip_address> "<command> >/dev/null 2>&1 &"


# start NFD on all devices
#ssh ${username}@${lenovoWiFiIP} "nohup nfd-start >/dev/null 2>/dev/null </dev/null &"
#ssh ${username}@${rPi3WiFiIP} "nohup nfd-start >/dev/null 2>/dev/null </dev/null &"
#ssh ${username}@${rPi4WiFiIP} "nohup nfd-start >/dev/null 2>/dev/null </dev/null &"
#ssh ${username}@${lenovoWiFiIP} "nfd-start >/dev/null 2>&1 &"
#ssh ${username}@${rPi3WiFiIP} "nfd-start >/dev/null 2>&1 &"
#ssh ${username}@${rPi4WiFiIP} "nfd-start >/dev/null 2>&1 &"

# create the faces
sleep 1; ssh ${username}@${lenovoWiFiIP} "nfdc face create remote ether://[${rPi4ETHMAC}] local dev://${lenovoETHinterface} persistency permanent >/dev/null 2>&1 &"
sleep 1; ssh ${username}@${rPi4WiFiIP} "nfdc face create remote ether://[${lenovoETHMAC}] local dev://${rPi4ETHinterface} persistency permanent >/dev/null 2>&1 &"


# add routes for all the PREFIXes to all nodes
sleep 1; ssh ${username}@${lenovoWiFiIP} "nfdc route add /interCACHE ether://[${rPi4ETHMAC}] >/dev/null 2>&1 &"
sleep 1; ssh ${username}@${rPi4WiFiIP} "nfdc route add /interCACHE ether://[${rPi4ETHMAC}] >/dev/null 2>&1 &"

#sleep 1; ssh ${username}@${lenovoWiFiIP} "nfdc route add /interCACHE/sensor udp://${rPi4WiFiIP} >/dev/null 2>&1 &"
#sleep 1; ssh ${username}@${lenovoWiFiIP} "nfdc route add /interCACHE/service1 udp://${rPi4WiFiIP} >/dev/null 2>&1 &"
#sleep 1; ssh ${username}@${lenovoWiFiIP} "nfdc route add /interCACHE/service2 udp://${rPi4WiFiIP} >/dev/null 2>&1 &"
#sleep 1; ssh ${username}@${lenovoWiFiIP} "nfdc route add /interCACHE/service3 udp://${rPi4WiFiIP} >/dev/null 2>&1 &"
#sleep 1; ssh ${username}@${lenovoWiFiIP} "nfdc route add /interCACHE/service4 udp://${rPi4WiFiIP} >/dev/null 2>&1 &"
#sleep 1; ssh ${username}@${rPi4WiFiIP} "nfdc route add /interCACHE/sensor udp://${rPi4WiFiIP} >/dev/null 2>&1 &"
#sleep 1; ssh ${username}@${rPi4WiFiIP} "nfdc route add /interCACHE/service1 udp://${rPi4WiFiIP} >/dev/null 2>&1 &"
#sleep 1; ssh ${username}@${rPi4WiFiIP} "nfdc route add /interCACHE/service2 udp://${rPi4WiFiIP} >/dev/null 2>&1 &"
#sleep 1; ssh ${username}@${rPi4WiFiIP} "nfdc route add /interCACHE/service3 udp://${rPi4WiFiIP} >/dev/null 2>&1 &"
#sleep 1; ssh ${username}@${rPi4WiFiIP} "nfdc route add /interCACHE/service4 udp://${rPi4WiFiIP} >/dev/null 2>&1 &"

#sleep 1; ssh ${username}@${lenovoWiFiIP} "nfdc route add /interCACHE/sensor udp://${rPi3WiFiIP} >/dev/null 2>&1 &"
#sleep 1; ssh ${username}@${lenovoWiFiIP} "nfdc route add /interCACHE/service1 udp://${rPi4WiFiIP} >/dev/null 2>&1 &"
#sleep 1; ssh ${username}@${lenovoWiFiIP} "nfdc route add /interCACHE/service2 udp://${rPi3WiFiIP} >/dev/null 2>&1 &"
#sleep 1; ssh ${username}@${lenovoWiFiIP} "nfdc route add /interCACHE/service3 udp://${rPi4WiFiIP} >/dev/null 2>&1 &"
#sleep 1; ssh ${username}@${lenovoWiFiIP} "nfdc route add /interCACHE/service4 udp://${rPi4WiFiIP} >/dev/null 2>&1 &"

#sleep 1; ssh ${username}@${rPi4WiFiIP} "nfdc route add /interCACHE/sensor udp://${rPi3WiFiIP} >/dev/null 2>&1 &"
#sleep 1; ssh ${username}@${rPi4WiFiIP} "nfdc route add /interCACHE/service1 udp://${rPi4WiFiIP} >/dev/null 2>&1 &"
#sleep 1; ssh ${username}@${rPi4WiFiIP} "nfdc route add /interCACHE/service2 udp://${rPi3WiFiIP} >/dev/null 2>&1 &"
#sleep 1; ssh ${username}@${rPi4WiFiIP} "nfdc route add /interCACHE/service3 udp://${rPi4WiFiIP} >/dev/null 2>&1 &"
#sleep 1; ssh ${username}@${rPi4WiFiIP} "nfdc route add /interCACHE/service4 udp://${rPi4WiFiIP} >/dev/null 2>&1 &"

#sleep 1; ssh ${username}@${rPi3WiFiIP} "nfdc route add /interCACHE/sensor udp://${rPi3WiFiIP} >/dev/null 2>&1 &"
#sleep 1; ssh ${username}@${rPi3WiFiIP} "nfdc route add /interCACHE/service1 udp://${rPi4WiFiIP} >/dev/null 2>&1 &"
#sleep 1; ssh ${username}@${rPi3WiFiIP} "nfdc route add /interCACHE/service2 udp://${rPi3WiFiIP} >/dev/null 2>&1 &"
#sleep 1; ssh ${username}@${rPi3WiFiIP} "nfdc route add /interCACHE/service3 udp://${rPi4WiFiIP} >/dev/null 2>&1 &"
#sleep 1; ssh ${username}@${rPi3WiFiIP} "nfdc route add /interCACHE/service4 udp://${rPi4WiFiIP} >/dev/null 2>&1 &"

#sleep 1; ssh ${username}@${rPi4WiFiIP} "nfdc route add /interCACHE udp://${rPi4WiFiIP} >/dev/null 2>&1 &"
#sleep 1; ssh ${username}@${rPi4WiFiIP} "nfdc route add /interCACHE/sensor udp://${rPi3WiFiIP} >/dev/null 2>&1 &"
#sleep 1; ssh ${username}@${rPi4WiFiIP} "nfdc route add /interCACHE/service2 udp://${rPi3WiFiIP} >/dev/null 2>&1 &"
#sleep 1; ssh ${username}@${rPi4WiFiIP} "nfdc route add /interCACHE/service4 udp://${rPi3WiFiIP} >/dev/null 2>&1 &"

#sleep 1; ssh ${username}@${rPi3WiFiIP} "nfdc route add /interCACHE udp://${rPi3WiFiIP} >/dev/null 2>&1 &"
#sleep 1; ssh ${username}@${rPi3WiFiIP} "nfdc route add /interCACHE/sensor udp://${jetsonNanoETHIP} >/dev/null 2>&1 &"
#sleep 1; ssh ${username}@${rPi3WiFiIP} "nfdc route add /interCACHE/service1 udp://${rPi4WiFiIP} >/dev/null 2>&1 &"
#sleep 1; ssh ${username}@${rPi3WiFiIP} "nfdc route add /interCACHE/service3 udp://${rPi4WiFiIP} >/dev/null 2>&1 &"

#sleep 1; ssh ${username}@${jetsonNanoETHIP} "nfdc route add /interCACHE udp://${jetsonNanoETHIP} >/dev/null 2>&1 &"
#sleep 1; ssh ${username}@${jetsonNanoETHIP} "nfdc route add /interCACHE/service1 udp://${rPi3WiFiIP} >/dev/null 2>&1 &"
#sleep 1; ssh ${username}@${jetsonNanoETHIP} "nfdc route add /interCACHE/service2 udp://${rPi3WiFiIP} >/dev/null 2>&1 &"
#sleep 1; ssh ${username}@${jetsonNanoETHIP} "nfdc route add /interCACHE/service3 udp://${rPi3WiFiIP} >/dev/null 2>&1 &"
#sleep 1; ssh ${username}@${jetsonNanoETHIP} "nfdc route add /interCACHE/service4 udp://${rPi3WiFiIP} >/dev/null 2>&1 &"

# 4 DAG - Orchestrator A
# start producer application
#sleep 1; ssh ${username}@${rPi3WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-custom-app-producer /interCACHE /sensor >/dev/null 2>&1 &"
# start orchestratorA application
#sleep 1; ssh ${username}@${rPi3WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-dag-orchestratorA-app /interCACHE /serviceOrchestration >/dev/null 2>&1 &"
# start forwarder application(s)
#sleep 1; ssh ${username}@${rPi3WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceA-app /interCACHE /service1 >/dev/null 2>&1 &"
#sleep 1; ssh ${username}@${rPi3WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceA-app /interCACHE /service2 >/dev/null 2>&1 &"
#sleep 1; ssh ${username}@${rPi3WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceA-app /interCACHE /service3 >/dev/null 2>&1 &"
#sleep 1; ssh ${username}@${rPi3WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceA-app /interCACHE /service4 >/dev/null 2>&1 &"
# start consumer application (locally so that we see the final print statements)
#sleep 1; ~/mini-ndn/dl/ndn-cxx/build/examples/cabeee-custom-app-consumer /interCACHE ~/mini-ndn/workflows/4dag.json 1


# 4 DAG - Orchestrator B
# start producer application
#sleep 1; ssh ${username}@${rPi3WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-custom-app-producer /interCACHE /sensor >/dev/null 2>&1 &"
# start orchestratorA application
#sleep 1; ssh ${username}@${rPi3WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-dag-orchestratorB-app /interCACHE /serviceOrchestration >/dev/null 2>&1 &"
# start forwarder application(s)
#sleep 1; ssh ${username}@${rPi3WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceB-app /interCACHE /service1 >/dev/null 2>&1 &"
#sleep 1; ssh ${username}@${rPi3WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceB-app /interCACHE /service2 >/dev/null 2>&1 &"
#sleep 1; ssh ${username}@${rPi3WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceB-app /interCACHE /service3 >/dev/null 2>&1 &"
#sleep 1; ssh ${username}@${rPi3WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceB-app /interCACHE /service4 >/dev/null 2>&1 &"
# start consumer application (locally so that we see the final print statements)
#sleep 1; ~/mini-ndn/dl/ndn-cxx/build/examples/cabeee-custom-app-consumer /interCACHE ~/mini-ndn/workflows/4dag.json 2



# 4 DAG - interCACHE Forwarder
# start producer application
#sleep 1; ssh ${username}@${rPi4WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-custom-app-producer /interCACHE /sensor >/dev/null 2>&1 &"
# start forwarder application(s)
#sleep 1; ssh ${username}@${rPi4WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-dag-forwarder-app /interCACHE /service1 >/dev/null 2>&1 &"
#sleep 1; ssh ${username}@${rPi4WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-dag-forwarder-app /interCACHE /service2 >/dev/null 2>&1 &"
#sleep 1; ssh ${username}@${rPi4WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-dag-forwarder-app /interCACHE /service3 >/dev/null 2>&1 &"
#sleep 1; ssh ${username}@${rPi4WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-dag-forwarder-app /interCACHE /service4 >/dev/null 2>&1 &"
# start consumer application (locally so that we see the final print statements)
#sleep 1; ~/mini-ndn/dl/ndn-cxx/build/examples/cabeee-custom-app-consumer /interCACHE ~/mini-ndn/workflows/4dag.json 0

# 4 DAG - interCACHE Forwarder
# start producer application
sleep 1; ssh ${username}@${rPi4WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-custom-app-producer /interCACHE /sensor >/dev/null 2>&1 &"
# start forwarder application(s)
sleep 1; ssh ${username}@${rPi4WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-dag-forwarder-app /interCACHE /service1 >/dev/null 2>&1 &"
sleep 1; ssh ${username}@${rPi4WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-dag-forwarder-app /interCACHE /service2 >/dev/null 2>&1 &"
sleep 1; ssh ${username}@${rPi4WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-dag-forwarder-app /interCACHE /service3 >/dev/null 2>&1 &"
sleep 1; ssh ${username}@${rPi4WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-dag-forwarder-app /interCACHE /service4 >/dev/null 2>&1 &"
# start consumer application (locally so that we see the final print statements)
sleep 1; ~/mini-ndn/dl/ndn-cxx/build/examples/cabeee-custom-app-consumer /interCACHE ~/mini-ndn/workflows/4dag.json 0





# 20 Linear


# 20 Parallel


# 20 Sensor (Parallel)


# 8 DAG


# 8 DAG w/ caching







