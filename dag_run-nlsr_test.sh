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
jetsonETHIP=192.168.20.145
rPi4ETHIP=192.168.20.146
rPi4WiFiIP=192.168.20.147
rPi3ETHIP=192.168.20.150
rPi3WiFiIP=192.168.20.151
jetsonUSBETHIP=192.168.20.174

lenovoETHMAC=d8:cb:8a:bc:a3:94
rPi4ETHMAC=d8:3a:dd:2e:c5:1f
rPi3ETHMAC=b8:27:eb:19:bf:bf
rPi3USBETHMAC=a0:ce:c8:cf:24:17
jetsonETHMAC=00:00:00:00:00:01
jetsonUSBETHMAC=00:10:60:b1:f1:1b

lenovoETHinterface=eno1
rPi4ETHinterface=eth0
rPi3ETHinterface=eth0
rPi3USBETHinterface=enxa0cec8cf2417
jetsonETHinterface=eth0
jetsonUSBETHinterface=eth1

sleep=0.1

#clear


# to run <command> remotely:
#ssh <username>@<ip_address> "nohup <command> >/dev/null 2>/dev/null </dev/null &"
# or
#ssh <username>@<ip_address> "<command> >/dev/null 2>&1 &"

# stop NFD on all devices to clear caches and forwarding table entries
ssh ${username}@${rPi4WiFiIP} "nfd-stop >/dev/null 2>&1 &"
ssh ${username}@${rPi3WiFiIP} "nfd-stop >/dev/null 2>&1 &"
ssh ${username}@${jetsonETHIP} "nfd-stop >/dev/null 2>&1 &"

# start NFD on all devices
ssh ${username}@${rPi4WiFiIP} "nfd-start >/dev/null 2>&1 &"
ssh ${username}@${rPi3WiFiIP} "nfd-start >/dev/null 2>&1 &"
ssh ${username}@${jetsonETHIP} "nfd-start >/dev/null 2>&1 &"


# create the faces
sleep ${sleep}; ssh ${username}@${rPi4WiFiIP} "nfdc face create remote ether://[${rPi3ETHMAC}] local dev://${rPi4ETHinterface} persistency permanent >/dev/null 2>&1 &"
sleep ${sleep}; ssh ${username}@${rPi3WiFiIP} "nfdc face create remote ether://[${rPi4ETHMAC}] local dev://${rPi3ETHinterface} persistency permanent >/dev/null 2>&1 &"
sleep ${sleep}; ssh ${username}@${rPi3WiFiIP} "nfdc face create remote ether://[${jetsonUSBETHMAC}] local dev://${rPi3USBETHinterface} persistency permanent >/dev/null 2>&1 &"
sleep ${sleep}; ssh ${username}@${jetsonETHIP} "nfdc face create remote ether://[${rPi3USBETHMAC}] local dev://${jetsonUSBETHinterface} persistency permanent >/dev/null 2>&1 &"


# add routes for all the PREFIXes to all nodes
#sleep ${sleep}; ssh ${username}@${rPi4WiFiIP} "nfdc route add /interCACHE ether://[${rPi3ETHMAC}] >/dev/null 2>&1 &"

#sleep ${sleep}; ssh ${username}@${rPi3WiFiIP} "nfdc route add /interCACHE ether://[${rPi3ETHMAC}] >/dev/null 2>&1 &"
#sleep ${sleep}; ssh ${username}@${rPi3WiFiIP} "nfdc route add /interCACHE/sensor ether://[${jetsonUSBETHMAC}] >/dev/null 2>&1 &"
#sleep ${sleep}; ssh ${username}@${rPi3WiFiIP} "nfdc route add /interCACHE/service2 ether://[${jetsonUSBETHMAC}] >/dev/null 2>&1 &"
#sleep ${sleep}; ssh ${username}@${rPi3WiFiIP} "nfdc route add /interCACHE/service4 ether://[${jetsonUSBETHMAC}] >/dev/null 2>&1 &"

#sleep ${sleep}; ssh ${username}@${jetsonETHIP} "nfdc route add /interCACHE ether://[${jetsonUSBETHMAC}] >/dev/null 2>&1 &"
#sleep ${sleep}; ssh ${username}@${jetsonETHIP} "nfdc route add /interCACHE/service1 ether://[${rPi3USBETHMAC}] >/dev/null 2>&1 &"
#sleep ${sleep}; ssh ${username}@${jetsonETHIP} "nfdc route add /interCACHE/service3 ether://[${rPi3USBETHMAC}] >/dev/null 2>&1 &"





# 4 DAG - interCACHE Forwarder
# start producer application
#sleep ${sleep}; ssh ${username}@${jetsonETHIP} "~/ndn/ndn-cxx/build/examples/cabeee-custom-app-producer /interCACHE /sensor >/dev/null 2>&1 &"
# start forwarder application(s)
#sleep ${sleep}; ssh ${username}@${rPi3WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-dag-forwarder-app /interCACHE /service1 >/dev/null 2>&1 &"
#sleep ${sleep}; ssh ${username}@${jetsonETHIP} "~/ndn/ndn-cxx/build/examples/cabeee-dag-forwarder-app /interCACHE /service2 >/dev/null 2>&1 &"
#sleep ${sleep}; ssh ${username}@${rPi3WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-dag-forwarder-app /interCACHE /service3 >/dev/null 2>&1 &"
#sleep ${sleep}; ssh ${username}@${jetsonETHIP} "~/ndn/ndn-cxx/build/examples/cabeee-dag-forwarder-app /interCACHE /service4 >/dev/null 2>&1 &"







#sleep ${sleep}; ssh ${username}@${rPi4WiFiIP} "sudo nlsr -f ~/mini-ndn/dl/NLSR/nlsr.conf >/dev/null 2>&1 &"
#sleep ${sleep}; ssh ${username}@${jetsonETHIP} "sudo nlsr -f ~/ndn/NLSR/nlsr.conf >/dev/null 2>&1 &"
#sleep ${sleep}; ssh ${username}@${rPi3WiFiIP} "sudo nlsr -f ~/ndn/NLSR/nlsr.conf >/dev/null 2>&1 &"




sleep 1


# start consumer application (not in the background, so that we see the final print statements)
#sleep ${sleep}; ssh ${username}@${rPi4WiFiIP} "~/mini-ndn/dl/ndn-cxx/build/examples/cabeee-custom-app-consumer /interCACHE ~/mini-ndn/workflows/4dag.json 0"







# stop NFD on all devices
#ssh ${username}@${rPi4WiFiIP} "nfd-stop >/dev/null 2>&1 &"
#ssh ${username}@${rPi3WiFiIP} "nfd-stop >/dev/null 2>&1 &"
#ssh ${username}@${jetsonETHIP} "nfd-stop >/dev/null 2>&1 &"



