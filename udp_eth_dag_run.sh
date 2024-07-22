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
lenovoETHIP=192.168.20.144
jetsonNanoETHIP=192.168.20.145
rPi4ETHIP=192.168.20.146
rPi4WiFiIP=192.168.20.147
rPi3ETHIP=192.168.20.150
rPi3WiFiIP=192.168.20.151
jetsonNanoUSBETHIP=192.168.20.174

lenovoETHMAC=D8:CB:8A:BC:A3:94
rPi4ETHMAC=d8:3a:dd:2e:c5:1f
rPi3ETHMAC=B8:27:EB:19:BF:BF
rPi3USBETHMAC=a0:ce:c8:cf:24:17
jetsonNanoETHMAC=00:00:00:00:00:01
jetsonNanoUSBETHMAC=00:10:60:b1:f1:1b

lenovoETHinterface=eno1
#rPi4ETHinterface=eth0
rPi3ETHinterface=eth0
rPi3USBETHinterface=enxa0cec8cf2417
jetsonNanoETHinterface=eth0
jetsonNanoUSBETHinterface=eth1

sleep=0.1

#clear


# to run <command> remotely:
#ssh <username>@<ip_address> "nohup <command> >/dev/null 2>/dev/null </dev/null &"
# or
#ssh <username>@<ip_address> "<command> >/dev/null 2>&1 &"

# stop NFD on all devices to clear caches and forwarding table entries
ssh ${username}@${lenovoWiFiIP} "nfd-stop >/dev/null 2>&1 &"
ssh ${username}@${rPi3WiFiIP} "nfd-stop >/dev/null 2>&1 &"
#ssh ${username}@${rPi4WiFiIP} "nfd-stop >/dev/null 2>&1 &"
ssh ${username}@${jetsonNanoETHIP} "nfd-stop >/dev/null 2>&1 &"

# start NFD on all devices
ssh ${username}@${lenovoWiFiIP} "nfd-start >/dev/null 2>&1 &"
ssh ${username}@${rPi3WiFiIP} "nfd-start >/dev/null 2>&1 &"
#ssh ${username}@${rPi4WiFiIP} "nfd-start >/dev/null 2>&1 &"
ssh ${username}@${jetsonNanoETHIP} "nfd-start >/dev/null 2>&1 &"


# create the faces
sleep ${sleep}; ssh ${username}@${lenovoWiFiIP} "nfdc face create remote udp://${rPi3ETHIP} >/dev/null 2>&1 &"
sleep ${sleep}; ssh ${username}@${rPi3WiFiIP} "nfdc face create remote udp://${lenovoETHIP} >/dev/null 2>&1 &"
sleep ${sleep}; ssh ${username}@${rPi3WiFiIP} "nfdc face create remote udp://${jetsonNanoETHIP} >/dev/null 2>&1 &"
sleep ${sleep}; ssh ${username}@${jetsonNanoETHIP} "nfdc face create remote udp://${rPi3ETHIP} >/dev/null 2>&1 &"


# add routes for all the PREFIXes to all nodes
sleep ${sleep}; ssh ${username}@${lenovoWiFiIP} "nfdc route add /interCACHE udp://${rPi3ETHIP} >/dev/null 2>&1 &"
#sleep ${sleep}; ssh ${username}@${rPi4WiFiIP} "nfdc route add /interCACHE udp://${rPi4WiFiIP} >/dev/null 2>&1 &"

#sleep ${sleep}; ssh ${username}@${lenovoWiFiIP} "nfdc route add /interCACHE/sensor udp://${rPi4WiFiIP} >/dev/null 2>&1 &"
#sleep ${sleep}; ssh ${username}@${lenovoWiFiIP} "nfdc route add /interCACHE/service1 udp://${rPi4WiFiIP} >/dev/null 2>&1 &"
#sleep ${sleep}; ssh ${username}@${lenovoWiFiIP} "nfdc route add /interCACHE/service2 udp://${rPi4WiFiIP} >/dev/null 2>&1 &"
#sleep ${sleep}; ssh ${username}@${lenovoWiFiIP} "nfdc route add /interCACHE/service3 udp://${rPi4WiFiIP} >/dev/null 2>&1 &"
#sleep ${sleep}; ssh ${username}@${lenovoWiFiIP} "nfdc route add /interCACHE/service4 udp://${rPi4WiFiIP} >/dev/null 2>&1 &"
#sleep ${sleep}; ssh ${username}@${rPi4WiFiIP} "nfdc route add /interCACHE/sensor udp://${rPi4WiFiIP} >/dev/null 2>&1 &"
#sleep ${sleep}; ssh ${username}@${rPi4WiFiIP} "nfdc route add /interCACHE/service1 udp://${rPi4WiFiIP} >/dev/null 2>&1 &"
#sleep ${sleep}; ssh ${username}@${rPi4WiFiIP} "nfdc route add /interCACHE/service2 udp://${rPi4WiFiIP} >/dev/null 2>&1 &"
#sleep ${sleep}; ssh ${username}@${rPi4WiFiIP} "nfdc route add /interCACHE/service3 udp://${rPi4WiFiIP} >/dev/null 2>&1 &"
#sleep ${sleep}; ssh ${username}@${rPi4WiFiIP} "nfdc route add /interCACHE/service4 udp://${rPi4WiFiIP} >/dev/null 2>&1 &"

#sleep ${sleep}; ssh ${username}@${lenovoWiFiIP} "nfdc route add /interCACHE/sensor udp://${rPi3WiFiIP} >/dev/null 2>&1 &"
#sleep ${sleep}; ssh ${username}@${lenovoWiFiIP} "nfdc route add /interCACHE/service1 udp://${rPi4WiFiIP} >/dev/null 2>&1 &"
#sleep ${sleep}; ssh ${username}@${lenovoWiFiIP} "nfdc route add /interCACHE/service2 udp://${rPi3WiFiIP} >/dev/null 2>&1 &"
#sleep ${sleep}; ssh ${username}@${lenovoWiFiIP} "nfdc route add /interCACHE/service3 udp://${rPi4WiFiIP} >/dev/null 2>&1 &"
#sleep ${sleep}; ssh ${username}@${lenovoWiFiIP} "nfdc route add /interCACHE/service4 udp://${rPi4WiFiIP} >/dev/null 2>&1 &"

#sleep ${sleep}; ssh ${username}@${rPi4WiFiIP} "nfdc route add /interCACHE/sensor udp://${rPi3WiFiIP} >/dev/null 2>&1 &"
#sleep ${sleep}; ssh ${username}@${rPi4WiFiIP} "nfdc route add /interCACHE/service1 udp://${rPi4WiFiIP} >/dev/null 2>&1 &"
#sleep ${sleep}; ssh ${username}@${rPi4WiFiIP} "nfdc route add /interCACHE/service2 udp://${rPi3WiFiIP} >/dev/null 2>&1 &"
#sleep ${sleep}; ssh ${username}@${rPi4WiFiIP} "nfdc route add /interCACHE/service3 udp://${rPi4WiFiIP} >/dev/null 2>&1 &"
#sleep ${sleep}; ssh ${username}@${rPi4WiFiIP} "nfdc route add /interCACHE/service4 udp://${rPi4WiFiIP} >/dev/null 2>&1 &"

#sleep ${sleep}; ssh ${username}@${rPi3WiFiIP} "nfdc route add /interCACHE/sensor udp://${rPi3WiFiIP} >/dev/null 2>&1 &"
#sleep ${sleep}; ssh ${username}@${rPi3WiFiIP} "nfdc route add /interCACHE/service1 udp://${rPi4WiFiIP} >/dev/null 2>&1 &"
#sleep ${sleep}; ssh ${username}@${rPi3WiFiIP} "nfdc route add /interCACHE/service2 udp://${rPi3WiFiIP} >/dev/null 2>&1 &"
#sleep ${sleep}; ssh ${username}@${rPi3WiFiIP} "nfdc route add /interCACHE/service3 udp://${rPi4WiFiIP} >/dev/null 2>&1 &"
#sleep ${sleep}; ssh ${username}@${rPi3WiFiIP} "nfdc route add /interCACHE/service4 udp://${rPi4WiFiIP} >/dev/null 2>&1 &"

#sleep ${sleep}; ssh ${username}@${rPi4WiFiIP} "nfdc route add /interCACHE udp://${rPi4WiFiIP} >/dev/null 2>&1 &"
#sleep ${sleep}; ssh ${username}@${rPi4WiFiIP} "nfdc route add /interCACHE/sensor udp://${rPi3WiFiIP} >/dev/null 2>&1 &"
#sleep ${sleep}; ssh ${username}@${rPi4WiFiIP} "nfdc route add /interCACHE/service2 udp://${rPi3WiFiIP} >/dev/null 2>&1 &"
#sleep ${sleep}; ssh ${username}@${rPi4WiFiIP} "nfdc route add /interCACHE/service4 udp://${rPi3WiFiIP} >/dev/null 2>&1 &"

sleep ${sleep}; ssh ${username}@${rPi3WiFiIP} "nfdc route add /interCACHE udp://${rPi3ETHIP} >/dev/null 2>&1 &"
sleep ${sleep}; ssh ${username}@${rPi3WiFiIP} "nfdc route add /interCACHE/sensor udp://${jetsonNanoETHIP} >/dev/null 2>&1 &"
sleep ${sleep}; ssh ${username}@${rPi3WiFiIP} "nfdc route add /interCACHE/service2 udp://${jetsonNanoETHIP} >/dev/null 2>&1 &"
sleep ${sleep}; ssh ${username}@${rPi3WiFiIP} "nfdc route add /interCACHE/service4 udp://${jetsonNanoETHIP} >/dev/null 2>&1 &"

sleep ${sleep}; ssh ${username}@${jetsonNanoETHIP} "nfdc route add /interCACHE udp://${jetsonNanoETHIP} >/dev/null 2>&1 &"
sleep ${sleep}; ssh ${username}@${jetsonNanoETHIP} "nfdc route add /interCACHE/service1 udp://${rPi3ETHIP} >/dev/null 2>&1 &"
sleep ${sleep}; ssh ${username}@${jetsonNanoETHIP} "nfdc route add /interCACHE/service3 udp://${rPi3ETHIP} >/dev/null 2>&1 &"

# 4 DAG - Orchestrator A
# start producer application
#sleep ${sleep}; ssh ${username}@${rPi3WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-custom-app-producer /interCACHE /sensor >/dev/null 2>&1 &"
# start orchestratorA application
#sleep ${sleep}; ssh ${username}@${rPi3WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-dag-orchestratorA-app /interCACHE /serviceOrchestration >/dev/null 2>&1 &"
# start forwarder application(s)
#sleep ${sleep}; ssh ${username}@${rPi3WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceA-app /interCACHE /service1 >/dev/null 2>&1 &"
#sleep ${sleep}; ssh ${username}@${rPi3WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceA-app /interCACHE /service2 >/dev/null 2>&1 &"
#sleep ${sleep}; ssh ${username}@${rPi3WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceA-app /interCACHE /service3 >/dev/null 2>&1 &"
#sleep ${sleep}; ssh ${username}@${rPi3WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceA-app /interCACHE /service4 >/dev/null 2>&1 &"
# start consumer application (locally so that we see the final print statements)
#sleep ${sleep}; ~/mini-ndn/dl/ndn-cxx/build/examples/cabeee-custom-app-consumer /interCACHE ~/mini-ndn/workflows/4dag.json 1


# 4 DAG - Orchestrator B
# start producer application
#sleep ${sleep}; ssh ${username}@${rPi3WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-custom-app-producer /interCACHE /sensor >/dev/null 2>&1 &"
# start orchestratorA application
#sleep ${sleep}; ssh ${username}@${rPi3WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-dag-orchestratorB-app /interCACHE /serviceOrchestration >/dev/null 2>&1 &"
# start forwarder application(s)
#sleep ${sleep}; ssh ${username}@${rPi3WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceB-app /interCACHE /service1 >/dev/null 2>&1 &"
#sleep ${sleep}; ssh ${username}@${rPi3WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceB-app /interCACHE /service2 >/dev/null 2>&1 &"
#sleep ${sleep}; ssh ${username}@${rPi3WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceB-app /interCACHE /service3 >/dev/null 2>&1 &"
#sleep ${sleep}; ssh ${username}@${rPi3WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceB-app /interCACHE /service4 >/dev/null 2>&1 &"
# start consumer application (locally so that we see the final print statements)
#sleep ${sleep}; ~/mini-ndn/dl/ndn-cxx/build/examples/cabeee-custom-app-consumer /interCACHE ~/mini-ndn/workflows/4dag.json 2



# 4 DAG - interCACHE Forwarder
# start producer application
#sleep ${sleep}; ssh ${username}@${rPi4WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-custom-app-producer /interCACHE /sensor >/dev/null 2>&1 &"
# start forwarder application(s)
#sleep ${sleep}; ssh ${username}@${rPi4WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-dag-forwarder-app /interCACHE /service1 >/dev/null 2>&1 &"
#sleep ${sleep}; ssh ${username}@${rPi4WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-dag-forwarder-app /interCACHE /service2 >/dev/null 2>&1 &"
#sleep ${sleep}; ssh ${username}@${rPi4WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-dag-forwarder-app /interCACHE /service3 >/dev/null 2>&1 &"
#sleep ${sleep}; ssh ${username}@${rPi4WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-dag-forwarder-app /interCACHE /service4 >/dev/null 2>&1 &"
# start consumer application (locally so that we see the final print statements)
#sleep ${sleep}; ~/mini-ndn/dl/ndn-cxx/build/examples/cabeee-custom-app-consumer /interCACHE ~/mini-ndn/workflows/4dag.json 0

# 4 DAG - interCACHE Forwarder
# start producer application
sleep ${sleep}; ssh ${username}@${jetsonNanoETHIP} "~/ndn/ndn-cxx/build/examples/cabeee-custom-app-producer /interCACHE /sensor >/dev/null 2>&1 &"
# start forwarder application(s)
sleep ${sleep}; ssh ${username}@${rPi3WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-dag-forwarder-app /interCACHE /service1 >/dev/null 2>&1 &"
sleep ${sleep}; ssh ${username}@${jetsonNanoETHIP} "~/ndn/ndn-cxx/build/examples/cabeee-dag-forwarder-app /interCACHE /service2 >/dev/null 2>&1 &"
sleep ${sleep}; ssh ${username}@${rPi3WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-dag-forwarder-app /interCACHE /service3 >/dev/null 2>&1 &"
sleep ${sleep}; ssh ${username}@${jetsonNanoETHIP} "~/ndn/ndn-cxx/build/examples/cabeee-dag-forwarder-app /interCACHE /service4 >/dev/null 2>&1 &"
# start consumer application (not in the background, so that we see the final print statements)
sleep ${sleep}; ssh ${username}@${lenovoWiFiIP} "~/mini-ndn/dl/ndn-cxx/build/examples/cabeee-custom-app-consumer /interCACHE ~/mini-ndn/workflows/4dag.json 0"





# 20 Linear


# 20 Parallel


# 20 Sensor (Parallel)


# 8 DAG


# 8 DAG w/ caching




ssh ${username}@${lenovoWiFiIP} "nfd-stop >/dev/null 2>&1 &"
ssh ${username}@${rPi3WiFiIP} "nfd-stop >/dev/null 2>&1 &"
#ssh ${username}@${rPi4WiFiIP} "nfd-stop >/dev/null 2>&1 &"
ssh ${username}@${jetsonNanoETHIP} "nfd-stop >/dev/null 2>&1 &"



