#! /bin/bash


#----- THIS ONLY NEEDS TO BE RUN ONCE --------------------
#cd ~/ndn/ndn-cxx
#./waf clean
#./waf
#sudo ./waf install
#nfd-start
#---------------------------------------------------------

run_4DAG_OrchA=true
#run_4DAG_OrchB=true
#run_4DAG_nesco=true
#run_8DAG_OrchA=true
#run_8DAG_OrchB=true
#run_8DAG_nesco=true
#run_8DAG_Caching_OrchA=true
#run_8DAG_Caching_OrchB=true
#run_8DAG_Caching_nesco=true
#run_20Parallel_OrchA=true
#run_20Parallel_OrchB=true
#run_20Parallel_nesco=true
#run_20Sensor_OrchA=true
#run_20Sensor_OrchB=true
#run_20Sensor_nesco=true
#run_20Linear_OrchA=true
#run_20Linear_OrchB=true
#run_20Linear_nesco=true

PREFIX=orchA
#PREFIX=orchB
#PREFIX=nesco
#PREFIX=nescoSCOPT

username=cabeee

lenovoWiFiIP=192.168.20.143
lenovoETHIP=192.168.20.144
jetsonETHIP=192.168.20.145
consumerETHIP=192.168.20.146
consumerWiFiIP=192.168.20.147
rtr1ETHIP=192.168.20.150
rtr1WiFiIP=192.168.20.151
rtr2ETHIP=192.168.20.152
rtr2WiFiIP=192.168.20.153
rtr3ETHIP=192.168.20.154
rtr3WiFiIP=192.168.20.155
producerETHIP=192.168.20.156
producerWiFiIP=192.168.20.157

lenovoETHMAC=d8:cb:8a:bc:a3:94
consumerETHMAC=d8:3a:dd:2e:c5:1f
consumerWiFiMAC=d8:3a:dd:2e:c5:20
rtr1ETHMAC=b8:27:eb:19:bf:bf
rtr1WiFiMAC=b8:27:eb:4c:ea:ea
rtr1USBETHMAC=a0:ce:c8:cf:24:17
rtr2ETHMAC=b8:27:eb:be:80:60
rtr2WiFiMAC=b8:27:eb:eb:d5:35
rtr2USBETHMAC=00:50:b6:58:01:ed
rtr3ETHMAC=b8:27:eb:13:9e:0a
rtr3WiFiMAC=b8:27:eb:46:cb:5f
rtr3USBETHMAC=00:14:d1:b0:24:ed
producerETHMAC=b8:27:eb:a6:27:12
producerWiFiMAC=b8:27:eb:f3:72:47
jetsonETHMAC=00:00:00:00:00:01
jetsonUSBETHMAC=00:10:60:b1:f1:1b

lenovoETHinterface=eno1
consumerETHinterface=eth0
consumerWiFiinterface=wlan0
rtr1ETHinterface=eth0
rtr1WiFiinterface=wlan0
rtr1USBETHinterface=enxa0cec8cf2417
rtr2ETHinterface=eth0
rtr2WiFiinterface=wlan0
rtr2USBETHinterface=enx0050b65801ed
rtr3ETHinterface=eth0
rtr3WiFiinterface=wlan0
rtr3USBETHinterface=enx0014d1b024ed
producerETHinterface=eth0
producerWiFiinterface=wlan0
jetsonETHinterface=eth0
jetsonUSBETHinterface=eth1

sleep=0.1

clear


# to run <command> remotely:
#ssh <username>@<ip_address> "nohup <command> >/dev/null 2>/dev/null </dev/null &"
# or
#ssh <username>@<ip_address> "<command> >/dev/null 2>&1 &"

# stop NFD on all devices to clear caches and forwarding table entries
ssh ${username}@${consumerWiFiIP} "nfd-stop >/dev/null 2>&1 &"
ssh ${username}@${rtr3WiFiIP} "nfd-stop >/dev/null 2>&1 &"
ssh ${username}@${rtr2WiFiIP} "nfd-stop >/dev/null 2>&1 &"
ssh ${username}@${rtr1WiFiIP} "nfd-stop >/dev/null 2>&1 &"
ssh ${username}@${producerWiFiIP} "nfd-stop >/dev/null 2>&1 &"

# start NFD on all devices
ssh ${username}@${consumerWiFiIP} "nfd-start >/dev/null 2>&1 &"
ssh ${username}@${rtr3WiFiIP} "nfd-start >/dev/null 2>&1 &"
ssh ${username}@${rtr2WiFiIP} "nfd-start >/dev/null 2>&1 &"
ssh ${username}@${rtr1WiFiIP} "nfd-start >/dev/null 2>&1 &"
ssh ${username}@${producerWiFiIP} "nfd-start >/dev/null 2>&1 &"


# create the faces
sleep ${sleep}; ssh ${username}@${consumerWiFiIP} "nfdc face create remote ether://[${rtr3ETHMAC}] local dev://${consumerETHinterface} persistency permanent >/dev/null 2>&1 &"
sleep ${sleep}; ssh ${username}@${rtr3WiFiIP} "nfdc face create remote ether://[${consumerETHMAC}] local dev://${rtr3ETHinterface} persistency permanent >/dev/null 2>&1 &"
sleep ${sleep}; ssh ${username}@${rtr3WiFiIP} "nfdc face create remote ether://[${rtr2ETHMAC}] local dev://${rtr3ETHinterface} persistency permanent >/dev/null 2>&1 &"
sleep ${sleep}; ssh ${username}@${rtr2WiFiIP} "nfdc face create remote ether://[${rtr3ETHMAC}] local dev://${rtr2ETHinterface} persistency permanent >/dev/null 2>&1 &"
sleep ${sleep}; ssh ${username}@${rtr2WiFiIP} "nfdc face create remote ether://[${rtr1ETHMAC}] local dev://${rtr2ETHinterface} persistency permanent >/dev/null 2>&1 &"
sleep ${sleep}; ssh ${username}@${rtr1WiFiIP} "nfdc face create remote ether://[${rtr2ETHMAC}] local dev://${rtr1ETHinterface} persistency permanent >/dev/null 2>&1 &"
sleep ${sleep}; ssh ${username}@${rtr1WiFiIP} "nfdc face create remote ether://[${producerETHMAC}] local dev://${rtr1ETHinterface} persistency permanent >/dev/null 2>&1 &"
sleep ${sleep}; ssh ${username}@${producerWiFiIP} "nfdc face create remote ether://[${rtr1ETHMAC}] local dev://${producerETHinterface} persistency permanent >/dev/null 2>&1 &"


# add routes for all the PREFIXes to all nodes
if [ $run_4DAG_OrchA ] || [ $run_4DAG_OrchB ] || [ $run_4DAG_nesco ] || [ $run_8DAG_OrchA ] || [ $run_8DAG_OrchB ] || [ $run_8DAG_nesco ] || [ $run_8DAG_Caching_OrchA ] || [ $run_8DAG_Caching_OrchB ] || [ $run_8DAG_Caching_nesco ]; then
	sleep ${sleep}; ssh ${username}@${consumerWiFiIP} "nfdc route add /${PREFIX} ether://[${rtr3ETHMAC}] >/dev/null 2>&1 &"
	
	sleep ${sleep}; ssh ${username}@${rtr3WiFiIP} "nfdc route add /${PREFIX} ether://[${rtr3ETHMAC}] >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr3WiFiIP} "nfdc route add /${PREFIX}/sensor ether://[${rtr2ETHMAC}] >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr3WiFiIP} "nfdc route add /${PREFIX}/service2 ether://[${rtr2ETHMAC}] >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr3WiFiIP} "nfdc route add /${PREFIX}/service3 ether://[${rtr2ETHMAC}] >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr3WiFiIP} "nfdc route add /${PREFIX}/service4 ether://[${rtr2ETHMAC}] >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr3WiFiIP} "nfdc route add /${PREFIX}/service6 ether://[${rtr2ETHMAC}] >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr3WiFiIP} "nfdc route add /${PREFIX}/service7 ether://[${rtr2ETHMAC}] >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr3WiFiIP} "nfdc route add /${PREFIX}/service8 ether://[${rtr2ETHMAC}] >/dev/null 2>&1 &"

	sleep ${sleep}; ssh ${username}@${rtr2WiFiIP} "nfdc route add /${PREFIX} ether://[${rtr2ETHMAC}] >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr2WiFiIP} "nfdc route add /${PREFIX}/sensor ether://[${rtr1ETHMAC}] >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr2WiFiIP} "nfdc route add /${PREFIX}/service2 ether://[${rtr1ETHMAC}] >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr2WiFiIP} "nfdc route add /${PREFIX}/service1 ether://[${rtr3ETHMAC}] >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr2WiFiIP} "nfdc route add /${PREFIX}/service6 ether://[${rtr1ETHMAC}] >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr2WiFiIP} "nfdc route add /${PREFIX}/service5 ether://[${rtr3ETHMAC}] >/dev/null 2>&1 &"

	sleep ${sleep}; ssh ${username}@${rtr1WiFiIP} "nfdc route add /${PREFIX} ether://[${rtr1ETHMAC}] >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr1WiFiIP} "nfdc route add /${PREFIX}/sensor ether://[${producerETHMAC}] >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr1WiFiIP} "nfdc route add /${PREFIX}/service1 ether://[${rtr2ETHMAC}] >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr1WiFiIP} "nfdc route add /${PREFIX}/service3 ether://[${rtr2ETHMAC}] >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr1WiFiIP} "nfdc route add /${PREFIX}/service4 ether://[${rtr2ETHMAC}] >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr1WiFiIP} "nfdc route add /${PREFIX}/service5 ether://[${rtr2ETHMAC}] >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr1WiFiIP} "nfdc route add /${PREFIX}/service7 ether://[${rtr2ETHMAC}] >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr1WiFiIP} "nfdc route add /${PREFIX}/service8 ether://[${rtr2ETHMAC}] >/dev/null 2>&1 &"

	sleep ${sleep}; ssh ${username}@${producerWiFiIP} "nfdc route add /${PREFIX} ether://[${producerETHMAC}] >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${producerWiFiIP} "nfdc route add /${PREFIX}/service1 ether://[${rtr1ETHMAC}] >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${producerWiFiIP} "nfdc route add /${PREFIX}/service2 ether://[${rtr1ETHMAC}] >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${producerWiFiIP} "nfdc route add /${PREFIX}/service3 ether://[${rtr1ETHMAC}] >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${producerWiFiIP} "nfdc route add /${PREFIX}/service4 ether://[${rtr1ETHMAC}] >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${producerWiFiIP} "nfdc route add /${PREFIX}/service5 ether://[${rtr1ETHMAC}] >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${producerWiFiIP} "nfdc route add /${PREFIX}/service6 ether://[${rtr1ETHMAC}] >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${producerWiFiIP} "nfdc route add /${PREFIX}/service7 ether://[${rtr1ETHMAC}] >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${producerWiFiIP} "nfdc route add /${PREFIX}/service8 ether://[${rtr1ETHMAC}] >/dev/null 2>&1 &"
fi

if [ $run_20Parallel_OrchA ] || [ $run_20Parallel_OrchB ] || [ $run_20Parallel_nesco ]; then
	sleep ${sleep}; ssh ${username}@${consumerWiFiIP} "nfdc route add /${PREFIX} ether://[${rtr3ETHMAC}] >/dev/null 2>&1 &"
	
	sleep ${sleep}; ssh ${username}@${rtr3WiFiIP} "nfdc route add /${PREFIX} ether://[${rtr3ETHMAC}] >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr3WiFiIP} "nfdc route add /${PREFIX}/sensor ether://[${rtr2ETHMAC}] >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr3WiFiIP} "nfdc route add /${PREFIX}/serviceP1 ether://[${rtr2ETHMAC}] >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr3WiFiIP} "nfdc route add /${PREFIX}/serviceP2 ether://[${rtr2ETHMAC}] >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr3WiFiIP} "nfdc route add /${PREFIX}/serviceP3 ether://[${rtr2ETHMAC}] >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr3WiFiIP} "nfdc route add /${PREFIX}/serviceP4 ether://[${rtr2ETHMAC}] >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr3WiFiIP} "nfdc route add /${PREFIX}/serviceP5 ether://[${rtr2ETHMAC}] >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr3WiFiIP} "nfdc route add /${PREFIX}/serviceP6 ether://[${rtr2ETHMAC}] >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr3WiFiIP} "nfdc route add /${PREFIX}/serviceP7 ether://[${rtr2ETHMAC}] >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr3WiFiIP} "nfdc route add /${PREFIX}/serviceP8 ether://[${rtr2ETHMAC}] >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr3WiFiIP} "nfdc route add /${PREFIX}/serviceP9 ether://[${rtr2ETHMAC}] >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr3WiFiIP} "nfdc route add /${PREFIX}/serviceP10 ether://[${rtr2ETHMAC}] >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr3WiFiIP} "nfdc route add /${PREFIX}/serviceP11 ether://[${rtr2ETHMAC}] >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr3WiFiIP} "nfdc route add /${PREFIX}/serviceP12 ether://[${rtr2ETHMAC}] >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr3WiFiIP} "nfdc route add /${PREFIX}/serviceP13 ether://[${rtr2ETHMAC}] >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr3WiFiIP} "nfdc route add /${PREFIX}/serviceP14 ether://[${rtr2ETHMAC}] >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr3WiFiIP} "nfdc route add /${PREFIX}/serviceP15 ether://[${rtr2ETHMAC}] >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr3WiFiIP} "nfdc route add /${PREFIX}/serviceP16 ether://[${rtr2ETHMAC}] >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr3WiFiIP} "nfdc route add /${PREFIX}/serviceP17 ether://[${rtr2ETHMAC}] >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr3WiFiIP} "nfdc route add /${PREFIX}/serviceP18 ether://[${rtr2ETHMAC}] >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr3WiFiIP} "nfdc route add /${PREFIX}/serviceP19 ether://[${rtr2ETHMAC}] >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr3WiFiIP} "nfdc route add /${PREFIX}/serviceP20 ether://[${rtr2ETHMAC}] >/dev/null 2>&1 &"

	sleep ${sleep}; ssh ${username}@${rtr2WiFiIP} "nfdc route add /${PREFIX}/sensor ether://[${rtr1ETHMAC}] >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr2WiFiIP} "nfdc route add /${PREFIX}/serviceP21 ether://[${rtr3ETHMAC}] >/dev/null 2>&1 &"

	sleep ${sleep}; ssh ${username}@${rtr1WiFiIP} "nfdc route add /${PREFIX}/serviceP1 ether://[${rtr2ETHMAC}] >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr1WiFiIP} "nfdc route add /${PREFIX}/serviceP2 ether://[${rtr2ETHMAC}] >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr1WiFiIP} "nfdc route add /${PREFIX}/serviceP3 ether://[${rtr2ETHMAC}] >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr1WiFiIP} "nfdc route add /${PREFIX}/serviceP4 ether://[${rtr2ETHMAC}] >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr1WiFiIP} "nfdc route add /${PREFIX}/serviceP5 ether://[${rtr2ETHMAC}] >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr1WiFiIP} "nfdc route add /${PREFIX}/serviceP6 ether://[${rtr2ETHMAC}] >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr1WiFiIP} "nfdc route add /${PREFIX}/serviceP7 ether://[${rtr2ETHMAC}] >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr1WiFiIP} "nfdc route add /${PREFIX}/serviceP8 ether://[${rtr2ETHMAC}] >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr1WiFiIP} "nfdc route add /${PREFIX}/serviceP9 ether://[${rtr2ETHMAC}] >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr1WiFiIP} "nfdc route add /${PREFIX}/serviceP10 ether://[${rtr2ETHMAC}] >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr1WiFiIP} "nfdc route add /${PREFIX}/serviceP11 ether://[${rtr2ETHMAC}] >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr1WiFiIP} "nfdc route add /${PREFIX}/serviceP12 ether://[${rtr2ETHMAC}] >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr1WiFiIP} "nfdc route add /${PREFIX}/serviceP13 ether://[${rtr2ETHMAC}] >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr1WiFiIP} "nfdc route add /${PREFIX}/serviceP14 ether://[${rtr2ETHMAC}] >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr1WiFiIP} "nfdc route add /${PREFIX}/serviceP15 ether://[${rtr2ETHMAC}] >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr1WiFiIP} "nfdc route add /${PREFIX}/serviceP16 ether://[${rtr2ETHMAC}] >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr1WiFiIP} "nfdc route add /${PREFIX}/serviceP17 ether://[${rtr2ETHMAC}] >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr1WiFiIP} "nfdc route add /${PREFIX}/serviceP18 ether://[${rtr2ETHMAC}] >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr1WiFiIP} "nfdc route add /${PREFIX}/serviceP19 ether://[${rtr2ETHMAC}] >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr1WiFiIP} "nfdc route add /${PREFIX}/serviceP20 ether://[${rtr2ETHMAC}] >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr1WiFiIP} "nfdc route add /${PREFIX}/serviceP21 ether://[${rtr2ETHMAC}] >/dev/null 2>&1 &"
fi

if [ $run_20Sensor_OrchA ] || [ $run_20Sensor_OrchB ] || [ $run_20Sensor_nesco ]; then
	sleep ${sleep}; ssh ${username}@${consumerWiFiIP} "nfdc route add /${PREFIX} ether://[${rtr3ETHMAC}] >/dev/null 2>&1 &"
	
	sleep ${sleep}; ssh ${username}@${rtr3WiFiIP} "nfdc route add /${PREFIX} ether://[${rtr3ETHMAC}] >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr3WiFiIP} "nfdc route add /${PREFIX}/sensor1 ether://[${rtr2ETHMAC}] >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr3WiFiIP} "nfdc route add /${PREFIX}/sensor2 ether://[${rtr2ETHMAC}] >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr3WiFiIP} "nfdc route add /${PREFIX}/sensor3 ether://[${rtr2ETHMAC}] >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr3WiFiIP} "nfdc route add /${PREFIX}/sensor4 ether://[${rtr2ETHMAC}] >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr3WiFiIP} "nfdc route add /${PREFIX}/sensor5 ether://[${rtr2ETHMAC}] >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr3WiFiIP} "nfdc route add /${PREFIX}/sensor6 ether://[${rtr2ETHMAC}] >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr3WiFiIP} "nfdc route add /${PREFIX}/sensor7 ether://[${rtr2ETHMAC}] >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr3WiFiIP} "nfdc route add /${PREFIX}/sensor8 ether://[${rtr2ETHMAC}] >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr3WiFiIP} "nfdc route add /${PREFIX}/sensor9 ether://[${rtr2ETHMAC}] >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr3WiFiIP} "nfdc route add /${PREFIX}/sensor10 ether://[${rtr2ETHMAC}] >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr3WiFiIP} "nfdc route add /${PREFIX}/sensor11 ether://[${rtr2ETHMAC}] >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr3WiFiIP} "nfdc route add /${PREFIX}/sensor12 ether://[${rtr2ETHMAC}] >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr3WiFiIP} "nfdc route add /${PREFIX}/sensor13 ether://[${rtr2ETHMAC}] >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr3WiFiIP} "nfdc route add /${PREFIX}/sensor14 ether://[${rtr2ETHMAC}] >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr3WiFiIP} "nfdc route add /${PREFIX}/sensor15 ether://[${rtr2ETHMAC}] >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr3WiFiIP} "nfdc route add /${PREFIX}/sensor16 ether://[${rtr2ETHMAC}] >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr3WiFiIP} "nfdc route add /${PREFIX}/sensor17 ether://[${rtr2ETHMAC}] >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr3WiFiIP} "nfdc route add /${PREFIX}/sensor18 ether://[${rtr2ETHMAC}] >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr3WiFiIP} "nfdc route add /${PREFIX}/sensor19 ether://[${rtr2ETHMAC}] >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr3WiFiIP} "nfdc route add /${PREFIX}/sensor20 ether://[${rtr2ETHMAC}] >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr3WiFiIP} "nfdc route add /${PREFIX}/serviceP1 ether://[${rtr2ETHMAC}] >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr3WiFiIP} "nfdc route add /${PREFIX}/serviceP2 ether://[${rtr2ETHMAC}] >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr3WiFiIP} "nfdc route add /${PREFIX}/serviceP3 ether://[${rtr2ETHMAC}] >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr3WiFiIP} "nfdc route add /${PREFIX}/serviceP4 ether://[${rtr2ETHMAC}] >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr3WiFiIP} "nfdc route add /${PREFIX}/serviceP5 ether://[${rtr2ETHMAC}] >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr3WiFiIP} "nfdc route add /${PREFIX}/serviceP6 ether://[${rtr2ETHMAC}] >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr3WiFiIP} "nfdc route add /${PREFIX}/serviceP7 ether://[${rtr2ETHMAC}] >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr3WiFiIP} "nfdc route add /${PREFIX}/serviceP8 ether://[${rtr2ETHMAC}] >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr3WiFiIP} "nfdc route add /${PREFIX}/serviceP9 ether://[${rtr2ETHMAC}] >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr3WiFiIP} "nfdc route add /${PREFIX}/serviceP10 ether://[${rtr2ETHMAC}] >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr3WiFiIP} "nfdc route add /${PREFIX}/serviceP11 ether://[${rtr2ETHMAC}] >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr3WiFiIP} "nfdc route add /${PREFIX}/serviceP12 ether://[${rtr2ETHMAC}] >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr3WiFiIP} "nfdc route add /${PREFIX}/serviceP13 ether://[${rtr2ETHMAC}] >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr3WiFiIP} "nfdc route add /${PREFIX}/serviceP14 ether://[${rtr2ETHMAC}] >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr3WiFiIP} "nfdc route add /${PREFIX}/serviceP15 ether://[${rtr2ETHMAC}] >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr3WiFiIP} "nfdc route add /${PREFIX}/serviceP16 ether://[${rtr2ETHMAC}] >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr3WiFiIP} "nfdc route add /${PREFIX}/serviceP17 ether://[${rtr2ETHMAC}] >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr3WiFiIP} "nfdc route add /${PREFIX}/serviceP18 ether://[${rtr2ETHMAC}] >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr3WiFiIP} "nfdc route add /${PREFIX}/serviceP19 ether://[${rtr2ETHMAC}] >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr3WiFiIP} "nfdc route add /${PREFIX}/serviceP20 ether://[${rtr2ETHMAC}] >/dev/null 2>&1 &"

	sleep ${sleep}; ssh ${username}@${rtr2WiFiIP} "nfdc route add /${PREFIX}/sensor1 ether://[${rtr1ETHMAC}] >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr2WiFiIP} "nfdc route add /${PREFIX}/sensor2 ether://[${rtr1ETHMAC}] >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr2WiFiIP} "nfdc route add /${PREFIX}/sensor3 ether://[${rtr1ETHMAC}] >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr2WiFiIP} "nfdc route add /${PREFIX}/sensor4 ether://[${rtr1ETHMAC}] >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr2WiFiIP} "nfdc route add /${PREFIX}/sensor5 ether://[${rtr1ETHMAC}] >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr2WiFiIP} "nfdc route add /${PREFIX}/sensor6 ether://[${rtr1ETHMAC}] >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr2WiFiIP} "nfdc route add /${PREFIX}/sensor7 ether://[${rtr1ETHMAC}] >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr2WiFiIP} "nfdc route add /${PREFIX}/sensor8 ether://[${rtr1ETHMAC}] >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr2WiFiIP} "nfdc route add /${PREFIX}/sensor9 ether://[${rtr1ETHMAC}] >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr2WiFiIP} "nfdc route add /${PREFIX}/sensor10 ether://[${rtr1ETHMAC}] >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr2WiFiIP} "nfdc route add /${PREFIX}/sensor11 ether://[${rtr1ETHMAC}] >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr2WiFiIP} "nfdc route add /${PREFIX}/sensor12 ether://[${rtr1ETHMAC}] >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr2WiFiIP} "nfdc route add /${PREFIX}/sensor13 ether://[${rtr1ETHMAC}] >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr2WiFiIP} "nfdc route add /${PREFIX}/sensor14 ether://[${rtr1ETHMAC}] >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr2WiFiIP} "nfdc route add /${PREFIX}/sensor15 ether://[${rtr1ETHMAC}] >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr2WiFiIP} "nfdc route add /${PREFIX}/sensor16 ether://[${rtr1ETHMAC}] >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr2WiFiIP} "nfdc route add /${PREFIX}/sensor17 ether://[${rtr1ETHMAC}] >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr2WiFiIP} "nfdc route add /${PREFIX}/sensor18 ether://[${rtr1ETHMAC}] >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr2WiFiIP} "nfdc route add /${PREFIX}/sensor19 ether://[${rtr1ETHMAC}] >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr2WiFiIP} "nfdc route add /${PREFIX}/sensor20 ether://[${rtr1ETHMAC}] >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr2WiFiIP} "nfdc route add /${PREFIX}/serviceP21 ether://[${rtr3ETHMAC}] >/dev/null 2>&1 &"

	sleep ${sleep}; ssh ${username}@${rtr1WiFiIP} "nfdc route add /${PREFIX}/serviceP1 ether://[${rtr2ETHMAC}] >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr1WiFiIP} "nfdc route add /${PREFIX}/serviceP2 ether://[${rtr2ETHMAC}] >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr1WiFiIP} "nfdc route add /${PREFIX}/serviceP3 ether://[${rtr2ETHMAC}] >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr1WiFiIP} "nfdc route add /${PREFIX}/serviceP4 ether://[${rtr2ETHMAC}] >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr1WiFiIP} "nfdc route add /${PREFIX}/serviceP5 ether://[${rtr2ETHMAC}] >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr1WiFiIP} "nfdc route add /${PREFIX}/serviceP6 ether://[${rtr2ETHMAC}] >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr1WiFiIP} "nfdc route add /${PREFIX}/serviceP7 ether://[${rtr2ETHMAC}] >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr1WiFiIP} "nfdc route add /${PREFIX}/serviceP8 ether://[${rtr2ETHMAC}] >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr1WiFiIP} "nfdc route add /${PREFIX}/serviceP9 ether://[${rtr2ETHMAC}] >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr1WiFiIP} "nfdc route add /${PREFIX}/serviceP10 ether://[${rtr2ETHMAC}] >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr1WiFiIP} "nfdc route add /${PREFIX}/serviceP11 ether://[${rtr2ETHMAC}] >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr1WiFiIP} "nfdc route add /${PREFIX}/serviceP12 ether://[${rtr2ETHMAC}] >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr1WiFiIP} "nfdc route add /${PREFIX}/serviceP13 ether://[${rtr2ETHMAC}] >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr1WiFiIP} "nfdc route add /${PREFIX}/serviceP14 ether://[${rtr2ETHMAC}] >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr1WiFiIP} "nfdc route add /${PREFIX}/serviceP15 ether://[${rtr2ETHMAC}] >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr1WiFiIP} "nfdc route add /${PREFIX}/serviceP16 ether://[${rtr2ETHMAC}] >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr1WiFiIP} "nfdc route add /${PREFIX}/serviceP17 ether://[${rtr2ETHMAC}] >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr1WiFiIP} "nfdc route add /${PREFIX}/serviceP18 ether://[${rtr2ETHMAC}] >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr1WiFiIP} "nfdc route add /${PREFIX}/serviceP19 ether://[${rtr2ETHMAC}] >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr1WiFiIP} "nfdc route add /${PREFIX}/serviceP20 ether://[${rtr2ETHMAC}] >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr1WiFiIP} "nfdc route add /${PREFIX}/serviceP21 ether://[${rtr2ETHMAC}] >/dev/null 2>&1 &"
fi

if [ $run_20Linear_OrchA ] || [ $run_20Linear_OrchB ] || [ $run_20Linear_nesco ]; then
	sleep ${sleep}; ssh ${username}@${consumerWiFiIP} "nfdc route add /${PREFIX} ether://[${rtr3ETHMAC}] >/dev/null 2>&1 &"
	
	sleep ${sleep}; ssh ${username}@${rtr3WiFiIP} "nfdc route add /${PREFIX} ether://[${rtr3ETHMAC}] >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr3WiFiIP} "nfdc route add /${PREFIX}/sensor ether://[${rtr2ETHMAC}] >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr3WiFiIP} "nfdc route add /${PREFIX}/serviceL1 ether://[${rtr2ETHMAC}] >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr3WiFiIP} "nfdc route add /${PREFIX}/serviceL3 ether://[${rtr2ETHMAC}] >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr3WiFiIP} "nfdc route add /${PREFIX}/serviceL5 ether://[${rtr2ETHMAC}] >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr3WiFiIP} "nfdc route add /${PREFIX}/serviceL7 ether://[${rtr2ETHMAC}] >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr3WiFiIP} "nfdc route add /${PREFIX}/serviceL9 ether://[${rtr2ETHMAC}] >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr3WiFiIP} "nfdc route add /${PREFIX}/serviceL11 ether://[${rtr2ETHMAC}] >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr3WiFiIP} "nfdc route add /${PREFIX}/serviceL13 ether://[${rtr2ETHMAC}] >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr3WiFiIP} "nfdc route add /${PREFIX}/serviceL15 ether://[${rtr2ETHMAC}] >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr3WiFiIP} "nfdc route add /${PREFIX}/serviceL17 ether://[${rtr2ETHMAC}] >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr3WiFiIP} "nfdc route add /${PREFIX}/serviceL19 ether://[${rtr2ETHMAC}] >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr3WiFiIP} "nfdc route add /${PREFIX}/serviceL2 ether://[${rtr2ETHMAC}] >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr3WiFiIP} "nfdc route add /${PREFIX}/serviceL6 ether://[${rtr2ETHMAC}] >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr3WiFiIP} "nfdc route add /${PREFIX}/serviceL10 ether://[${rtr2ETHMAC}] >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr3WiFiIP} "nfdc route add /${PREFIX}/serviceL14 ether://[${rtr2ETHMAC}] >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr3WiFiIP} "nfdc route add /${PREFIX}/serviceL18 ether://[${rtr2ETHMAC}] >/dev/null 2>&1 &"

	sleep ${sleep}; ssh ${username}@${rtr2WiFiIP} "nfdc route add /${PREFIX} ether://[${rtr2ETHMAC}] >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr2WiFiIP} "nfdc route add /${PREFIX}/sensor ether://[${rtr1ETHMAC}] >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr2WiFiIP} "nfdc route add /${PREFIX}/serviceL4 ether://[${rtr3ETHMAC}] >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr2WiFiIP} "nfdc route add /${PREFIX}/serviceL8 ether://[${rtr3ETHMAC}] >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr2WiFiIP} "nfdc route add /${PREFIX}/serviceL12 ether://[${rtr3ETHMAC}] >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr2WiFiIP} "nfdc route add /${PREFIX}/serviceL16 ether://[${rtr3ETHMAC}] >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr2WiFiIP} "nfdc route add /${PREFIX}/serviceL20 ether://[${rtr3ETHMAC}] >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr2WiFiIP} "nfdc route add /${PREFIX}/serviceL2 ether://[${rtr1ETHMAC}] >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr2WiFiIP} "nfdc route add /${PREFIX}/serviceL6 ether://[${rtr1ETHMAC}] >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr2WiFiIP} "nfdc route add /${PREFIX}/serviceL10 ether://[${rtr1ETHMAC}] >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr2WiFiIP} "nfdc route add /${PREFIX}/serviceL14 ether://[${rtr1ETHMAC}] >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr2WiFiIP} "nfdc route add /${PREFIX}/serviceL18 ether://[${rtr1ETHMAC}] >/dev/null 2>&1 &"

	sleep ${sleep}; ssh ${username}@${rtr1WiFiIP} "nfdc route add /${PREFIX} ether://[${rtr1ETHMAC}] >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr1WiFiIP} "nfdc route add /${PREFIX}/sensor ether://[${producerETHMAC}] >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr1WiFiIP} "nfdc route add /${PREFIX}/serviceL1 ether://[${rtr2ETHMAC}] >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr1WiFiIP} "nfdc route add /${PREFIX}/serviceL3 ether://[${rtr2ETHMAC}] >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr1WiFiIP} "nfdc route add /${PREFIX}/serviceL5 ether://[${rtr2ETHMAC}] >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr1WiFiIP} "nfdc route add /${PREFIX}/serviceL7 ether://[${rtr2ETHMAC}] >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr1WiFiIP} "nfdc route add /${PREFIX}/serviceL9 ether://[${rtr2ETHMAC}] >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr1WiFiIP} "nfdc route add /${PREFIX}/serviceL11 ether://[${rtr2ETHMAC}] >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr1WiFiIP} "nfdc route add /${PREFIX}/serviceL13 ether://[${rtr2ETHMAC}] >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr1WiFiIP} "nfdc route add /${PREFIX}/serviceL15 ether://[${rtr2ETHMAC}] >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr1WiFiIP} "nfdc route add /${PREFIX}/serviceL17 ether://[${rtr2ETHMAC}] >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr1WiFiIP} "nfdc route add /${PREFIX}/serviceL19 ether://[${rtr2ETHMAC}] >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr1WiFiIP} "nfdc route add /${PREFIX}/serviceL4 ether://[${rtr2ETHMAC}] >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr1WiFiIP} "nfdc route add /${PREFIX}/serviceL8 ether://[${rtr2ETHMAC}] >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr1WiFiIP} "nfdc route add /${PREFIX}/serviceL12 ether://[${rtr2ETHMAC}] >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr1WiFiIP} "nfdc route add /${PREFIX}/serviceL16 ether://[${rtr2ETHMAC}] >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr1WiFiIP} "nfdc route add /${PREFIX}/serviceL20 ether://[${rtr2ETHMAC}] >/dev/null 2>&1 &"

	sleep ${sleep}; ssh ${username}@${producerWiFiIP} "nfdc route add /${PREFIX} ether://[${producerETHMAC}] >/dev/null 2>&1 &"
	#sleep ${sleep}; ssh ${username}@${producerWiFiIP} "nfdc route add /${PREFIX}/serviceL1 ether://[${rtr1ETHMAC}] >/dev/null 2>&1 &"
	#sleep ${sleep}; ssh ${username}@${producerWiFiIP} "nfdc route add /${PREFIX}/serviceL2 ether://[${rtr1ETHMAC}] >/dev/null 2>&1 &"
	#sleep ${sleep}; ssh ${username}@${producerWiFiIP} "nfdc route add /${PREFIX}/serviceL3 ether://[${rtr1ETHMAC}] >/dev/null 2>&1 &"
	#sleep ${sleep}; ssh ${username}@${producerWiFiIP} "nfdc route add /${PREFIX}/serviceL4 ether://[${rtr1ETHMAC}] >/dev/null 2>&1 &"
	#sleep ${sleep}; ssh ${username}@${producerWiFiIP} "nfdc route add /${PREFIX}/serviceL5 ether://[${rtr1ETHMAC}] >/dev/null 2>&1 &"
	#sleep ${sleep}; ssh ${username}@${producerWiFiIP} "nfdc route add /${PREFIX}/serviceL6 ether://[${rtr1ETHMAC}] >/dev/null 2>&1 &"
	#sleep ${sleep}; ssh ${username}@${producerWiFiIP} "nfdc route add /${PREFIX}/serviceL7 ether://[${rtr1ETHMAC}] >/dev/null 2>&1 &"
	#sleep ${sleep}; ssh ${username}@${producerWiFiIP} "nfdc route add /${PREFIX}/serviceL8 ether://[${rtr1ETHMAC}] >/dev/null 2>&1 &"
	#sleep ${sleep}; ssh ${username}@${producerWiFiIP} "nfdc route add /${PREFIX}/serviceL9 ether://[${rtr1ETHMAC}] >/dev/null 2>&1 &"
	#sleep ${sleep}; ssh ${username}@${producerWiFiIP} "nfdc route add /${PREFIX}/serviceL10 ether://[${rtr1ETHMAC}] >/dev/null 2>&1 &"
	#sleep ${sleep}; ssh ${username}@${producerWiFiIP} "nfdc route add /${PREFIX}/serviceL11 ether://[${rtr1ETHMAC}] >/dev/null 2>&1 &"
	#sleep ${sleep}; ssh ${username}@${producerWiFiIP} "nfdc route add /${PREFIX}/serviceL12 ether://[${rtr1ETHMAC}] >/dev/null 2>&1 &"
	#sleep ${sleep}; ssh ${username}@${producerWiFiIP} "nfdc route add /${PREFIX}/serviceL13 ether://[${rtr1ETHMAC}] >/dev/null 2>&1 &"
	#sleep ${sleep}; ssh ${username}@${producerWiFiIP} "nfdc route add /${PREFIX}/serviceL14 ether://[${rtr1ETHMAC}] >/dev/null 2>&1 &"
	#sleep ${sleep}; ssh ${username}@${producerWiFiIP} "nfdc route add /${PREFIX}/serviceL15 ether://[${rtr1ETHMAC}] >/dev/null 2>&1 &"
	#sleep ${sleep}; ssh ${username}@${producerWiFiIP} "nfdc route add /${PREFIX}/serviceL16 ether://[${rtr1ETHMAC}] >/dev/null 2>&1 &"
	#sleep ${sleep}; ssh ${username}@${producerWiFiIP} "nfdc route add /${PREFIX}/serviceL17 ether://[${rtr1ETHMAC}] >/dev/null 2>&1 &"
	#sleep ${sleep}; ssh ${username}@${producerWiFiIP} "nfdc route add /${PREFIX}/serviceL18 ether://[${rtr1ETHMAC}] >/dev/null 2>&1 &"
	#sleep ${sleep}; ssh ${username}@${producerWiFiIP} "nfdc route add /${PREFIX}/serviceL19 ether://[${rtr1ETHMAC}] >/dev/null 2>&1 &"
	#sleep ${sleep}; ssh ${username}@${producerWiFiIP} "nfdc route add /${PREFIX}/serviceL20 ether://[${rtr1ETHMAC}] >/dev/null 2>&1 &"
fi




sleep 1




if [ $run_4DAG_OrchA ]; then
	# start producer application
	sleep ${sleep}; ssh ${username}@${producerWiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-custom-app-producer /${PREFIX} /sensor >/dev/null 2>&1 &"
	# start orchestratorA application
	sleep ${sleep}; ssh ${username}@${consumerWiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-dag-orchestratorA-app /${PREFIX} /serviceOrchestration >/dev/null 2>&1 &"
	# start forwarder application(s)
	sleep ${sleep}; ssh ${username}@${rtr3WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceA-app /${PREFIX} /service1 >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr1WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceA-app /${PREFIX} /service2 >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr2WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceA-app /${PREFIX} /service3 >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr2WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceA-app /${PREFIX} /service4 >/dev/null 2>&1 &"
	sleep 1
	# start consumer application (not in the background, so that we see the final print statements)
	sleep ${sleep}; ssh ${username}@${consumerWiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-custom-app-consumer /${PREFIX} ~/mini-ndn/workflows/4dag.json 1"
fi

if [ $run_4DAG_OrchB ]; then
	# start producer application
	sleep ${sleep}; ssh ${username}@${producerWiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-custom-app-producer /${PREFIX} /sensor >/dev/null 2>&1 &"
	# start orchestratorA application
	sleep ${sleep}; ssh ${username}@${consumerWiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-dag-orchestratorB-app /${PREFIX} /serviceOrchestration >/dev/null 2>&1 &"
	# start forwarder application(s)
	sleep ${sleep}; ssh ${username}@${rtr3WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceB-app /${PREFIX} /service1 >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr1WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceB-app /${PREFIX} /service2 >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr2WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceB-app /${PREFIX} /service3 >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr2WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceB-app /${PREFIX} /service4 >/dev/null 2>&1 &"
	sleep 1
	# start consumer application (not in the background, so that we see the final print statements)
	sleep ${sleep}; ssh ${username}@${consumerWiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-custom-app-consumer /${PREFIX} ~/mini-ndn/workflows/4dag.json 2"
fi

if [ $run_4DAG_nesco ]; then
	# start producer application
	sleep ${sleep}; ssh ${username}@${producerWiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-custom-app-producer /${PREFIX} /sensor >/dev/null 2>&1 &"
	# start forwarder application(s)
	sleep ${sleep}; ssh ${username}@${rtr3WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-dag-forwarder-app /${PREFIX} /service1 >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr1WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-dag-forwarder-app /${PREFIX} /service2 >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr2WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-dag-forwarder-app /${PREFIX} /service3 >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr2WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-dag-forwarder-app /${PREFIX} /service4 >/dev/null 2>&1 &"
	sleep 1
	# start consumer application (not in the background, so that we see the final print statements)
	sleep ${sleep}; ssh ${username}@${consumerWiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-custom-app-consumer /${PREFIX} ~/mini-ndn/workflows/4dag.json 0"
fi

if [ $run_8DAG_OrchA ]; then
	sleep ${sleep}; ssh ${username}@${producerWiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-custom-app-producer /${PREFIX} /sensor >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${consumerWiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-dag-orchestratorA-app /${PREFIX} /serviceOrchestration >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr3WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceA-app /${PREFIX} /service1 >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr1WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceA-app /${PREFIX} /service2 >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr2WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceA-app /${PREFIX} /service3 >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr2WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceA-app /${PREFIX} /service4 >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr3WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceA-app /${PREFIX} /service5 >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr1WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceA-app /${PREFIX} /service6 >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr2WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceA-app /${PREFIX} /service7 >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr2WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceA-app /${PREFIX} /service8 >/dev/null 2>&1 &"
	sleep 1
	sleep ${sleep}; ssh ${username}@${consumerWiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-custom-app-consumer /${PREFIX} ~/mini-ndn/workflows/8dag.json 1"
fi

if [ $run_8DAG_OrchB ]; then
	sleep ${sleep}; ssh ${username}@${producerWiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-custom-app-producer /${PREFIX} /sensor >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${consumerWiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-dag-orchestratorB-app /${PREFIX} /serviceOrchestration >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr3WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceB-app /${PREFIX} /service1 >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr1WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceB-app /${PREFIX} /service2 >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr2WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceB-app /${PREFIX} /service3 >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr2WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceB-app /${PREFIX} /service4 >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr3WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceB-app /${PREFIX} /service5 >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr1WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceB-app /${PREFIX} /service6 >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr2WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceB-app /${PREFIX} /service7 >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr2WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceB-app /${PREFIX} /service8 >/dev/null 2>&1 &"
	sleep 1
	sleep ${sleep}; ssh ${username}@${consumerWiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-custom-app-consumer /${PREFIX} ~/mini-ndn/workflows/8dag.json 2"

fi

if [ $run_8DAG_nesco ]; then
	sleep ${sleep}; ssh ${username}@${producerWiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-custom-app-producer /${PREFIX} /sensor >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr3WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-dag-forwarder-app /${PREFIX} /service1 >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr1WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-dag-forwarder-app /${PREFIX} /service2 >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr2WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-dag-forwarder-app /${PREFIX} /service3 >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr2WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-dag-forwarder-app /${PREFIX} /service4 >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr3WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-dag-forwarder-app /${PREFIX} /service5 >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr1WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-dag-forwarder-app /${PREFIX} /service6 >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr2WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-dag-forwarder-app /${PREFIX} /service7 >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr2WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-dag-forwarder-app /${PREFIX} /service8 >/dev/null 2>&1 &"
	sleep 1
	sleep ${sleep}; ssh ${username}@${consumerWiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-custom-app-consumer /${PREFIX} ~/mini-ndn/workflows/8dag.json 0"
fi

if [ $run_8DAG_Caching_OrchA ]; then
	sleep ${sleep}; ssh ${username}@${producerWiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-custom-app-producer /${PREFIX} /sensor >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${consumerWiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-dag-orchestratorA-app /${PREFIX} /serviceOrchestration >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr3WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceA-app /${PREFIX} /service1 >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr1WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceA-app /${PREFIX} /service2 >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr2WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceA-app /${PREFIX} /service3 >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr2WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceA-app /${PREFIX} /service4 >/dev/null 2>&1 &"
	sleep 1
	sleep ${sleep}; ssh ${username}@${consumerWiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-custom-app-consumer /${PREFIX} ~/mini-ndn/workflows/4dag.json 1"
	sleep 1
	sleep ${sleep}; ssh ${username}@${consumerWiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-dag-orchestratorA-reset-app /${PREFIX} /serviceOrchestration/reset >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr3WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceA-app /${PREFIX} /service5 >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr1WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceA-app /${PREFIX} /service6 >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr2WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceA-app /${PREFIX} /service7 >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr2WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceA-app /${PREFIX} /service8 >/dev/null 2>&1 &"
	sleep 1
	sleep ${sleep}; ssh ${username}@${consumerWiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-custom-app-consumer2 /${PREFIX} ~/mini-ndn/workflows/8dag.json 1"
fi

if [ $run_8DAG_Caching_OrchB ]; then
	sleep ${sleep}; ssh ${username}@${producerWiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-custom-app-producer /${PREFIX} /sensor >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${consumerWiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-dag-orchestratorB-app /${PREFIX} /serviceOrchestration >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr3WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceB-app /${PREFIX} /service1 >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr1WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceB-app /${PREFIX} /service2 >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr2WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceB-app /${PREFIX} /service3 >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr2WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceB-app /${PREFIX} /service4 >/dev/null 2>&1 &"
	sleep 1
	sleep ${sleep}; ssh ${username}@${consumerWiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-custom-app-consumer /${PREFIX} ~/mini-ndn/workflows/4dag.json 2"
	sleep 1
	sleep ${sleep}; ssh ${username}@${consumerWiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-dag-orchestratorA-reset-app /${PREFIX} /serviceOrchestration/reset >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr3WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceB-app /${PREFIX} /service5 >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr1WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceB-app /${PREFIX} /service6 >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr2WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceB-app /${PREFIX} /service7 >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr2WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceB-app /${PREFIX} /service8 >/dev/null 2>&1 &"
	sleep 1
	sleep ${sleep}; ssh ${username}@${consumerWiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-custom-app-consumer2 /${PREFIX} ~/mini-ndn/workflows/8dag.json 2"
fi

if [ $run_8DAG_Caching_nesco ]; then
	sleep ${sleep}; ssh ${username}@${producerWiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-custom-app-producer /${PREFIX} /sensor >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr3WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-dag-forwarder-app /${PREFIX} /service1 >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr1WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-dag-forwarder-app /${PREFIX} /service2 >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr2WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-dag-forwarder-app /${PREFIX} /service3 >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr2WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-dag-forwarder-app /${PREFIX} /service4 >/dev/null 2>&1 &"
	sleep 1
	sleep ${sleep}; ssh ${username}@${consumerWiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-custom-app-consumer /${PREFIX} ~/mini-ndn/workflows/4dag.json 0"
	sleep 1
	sleep ${sleep}; ssh ${username}@${rtr3WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-dag-forwarder-app /${PREFIX} /service5 >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr1WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-dag-forwarder-app /${PREFIX} /service6 >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr2WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-dag-forwarder-app /${PREFIX} /service7 >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr2WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-dag-forwarder-app /${PREFIX} /service8 >/dev/null 2>&1 &"
	sleep 1
	sleep ${sleep}; ssh ${username}@${consumerWiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-custom-app-consumer2 /${PREFIX} ~/mini-ndn/workflows/8dag.json 0"
fi

if [ $run_20Parallel_OrchA ]; then
	sleep ${sleep}; ssh ${username}@${rtr1WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-custom-app-producer /${PREFIX} /sensor >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${consumerWiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-dag-orchestratorA-app /${PREFIX} /serviceOrchestration >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr2WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceA-app /${PREFIX} /serviceP1 >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr2WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceA-app /${PREFIX} /serviceP2 >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr2WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceA-app /${PREFIX} /serviceP3 >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr2WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceA-app /${PREFIX} /serviceP4 >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr2WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceA-app /${PREFIX} /serviceP5 >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr2WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceA-app /${PREFIX} /serviceP6 >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr2WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceA-app /${PREFIX} /serviceP7 >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr2WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceA-app /${PREFIX} /serviceP8 >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr2WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceA-app /${PREFIX} /serviceP9 >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr2WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceA-app /${PREFIX} /serviceP10 >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr2WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceA-app /${PREFIX} /serviceP11 >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr2WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceA-app /${PREFIX} /serviceP12 >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr2WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceA-app /${PREFIX} /serviceP13 >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr2WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceA-app /${PREFIX} /serviceP14 >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr2WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceA-app /${PREFIX} /serviceP15 >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr2WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceA-app /${PREFIX} /serviceP16 >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr2WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceA-app /${PREFIX} /serviceP17 >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr2WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceA-app /${PREFIX} /serviceP18 >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr2WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceA-app /${PREFIX} /serviceP19 >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr2WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceA-app /${PREFIX} /serviceP20 >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr3WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceA-app /${PREFIX} /serviceP21 >/dev/null 2>&1 &"
	sleep 1
	sleep ${sleep}; ssh ${username}@${consumerWiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-custom-app-consumer /${PREFIX} ~/mini-ndn/workflows/20-parallel.json 1"
fi

if [ $run_20Parallel_OrchB ]; then
	sleep ${sleep}; ssh ${username}@${rtr1WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-custom-app-producer /${PREFIX} /sensor >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${consumerWiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-dag-orchestratorB-app /${PREFIX} /serviceOrchestration >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr2WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceB-app /${PREFIX} /serviceP1 >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr2WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceB-app /${PREFIX} /serviceP2 >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr2WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceB-app /${PREFIX} /serviceP3 >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr2WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceB-app /${PREFIX} /serviceP4 >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr2WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceB-app /${PREFIX} /serviceP5 >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr2WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceB-app /${PREFIX} /serviceP6 >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr2WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceB-app /${PREFIX} /serviceP7 >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr2WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceB-app /${PREFIX} /serviceP8 >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr2WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceB-app /${PREFIX} /serviceP9 >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr2WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceB-app /${PREFIX} /serviceP10 >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr2WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceB-app /${PREFIX} /serviceP11 >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr2WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceB-app /${PREFIX} /serviceP12 >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr2WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceB-app /${PREFIX} /serviceP13 >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr2WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceB-app /${PREFIX} /serviceP14 >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr2WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceB-app /${PREFIX} /serviceP15 >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr2WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceB-app /${PREFIX} /serviceP16 >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr2WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceB-app /${PREFIX} /serviceP17 >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr2WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceB-app /${PREFIX} /serviceP18 >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr2WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceB-app /${PREFIX} /serviceP19 >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr2WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceB-app /${PREFIX} /serviceP20 >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr3WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceB-app /${PREFIX} /serviceP21 >/dev/null 2>&1 &"
	sleep 1
	sleep ${sleep}; ssh ${username}@${consumerWiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-custom-app-consumer /${PREFIX} ~/mini-ndn/workflows/20-parallel.json 2"
fi

if [ $run_20Parallel_nesco ]; then
	sleep ${sleep}; ssh ${username}@${rtr1WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-custom-app-producer /${PREFIX} /sensor >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr2WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-dag-forwarder-app /${PREFIX} /serviceP1 >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr2WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-dag-forwarder-app /${PREFIX} /serviceP2 >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr2WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-dag-forwarder-app /${PREFIX} /serviceP3 >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr2WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-dag-forwarder-app /${PREFIX} /serviceP4 >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr2WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-dag-forwarder-app /${PREFIX} /serviceP5 >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr2WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-dag-forwarder-app /${PREFIX} /serviceP6 >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr2WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-dag-forwarder-app /${PREFIX} /serviceP7 >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr2WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-dag-forwarder-app /${PREFIX} /serviceP8 >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr2WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-dag-forwarder-app /${PREFIX} /serviceP9 >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr2WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-dag-forwarder-app /${PREFIX} /serviceP10 >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr2WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-dag-forwarder-app /${PREFIX} /serviceP11 >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr2WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-dag-forwarder-app /${PREFIX} /serviceP12 >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr2WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-dag-forwarder-app /${PREFIX} /serviceP13 >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr2WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-dag-forwarder-app /${PREFIX} /serviceP14 >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr2WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-dag-forwarder-app /${PREFIX} /serviceP15 >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr2WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-dag-forwarder-app /${PREFIX} /serviceP16 >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr2WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-dag-forwarder-app /${PREFIX} /serviceP17 >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr2WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-dag-forwarder-app /${PREFIX} /serviceP18 >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr2WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-dag-forwarder-app /${PREFIX} /serviceP19 >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr2WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-dag-forwarder-app /${PREFIX} /serviceP20 >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr3WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-dag-forwarder-app /${PREFIX} /serviceP21 >/dev/null 2>&1 &"
	sleep 1
	sleep ${sleep}; ssh ${username}@${consumerWiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-custom-app-consumer /${PREFIX} ~/mini-ndn/workflows/20-parallel.json 0"
fi

if [ $run_20Sensor_OrchA ]; then
	sleep ${sleep}; ssh ${username}@${rtr1WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-custom-app-producer /${PREFIX} /sensor1 >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr1WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-custom-app-producer /${PREFIX} /sensor2 >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr1WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-custom-app-producer /${PREFIX} /sensor3 >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr1WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-custom-app-producer /${PREFIX} /sensor4 >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr1WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-custom-app-producer /${PREFIX} /sensor5 >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr1WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-custom-app-producer /${PREFIX} /sensor6 >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr1WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-custom-app-producer /${PREFIX} /sensor7 >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr1WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-custom-app-producer /${PREFIX} /sensor8 >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr1WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-custom-app-producer /${PREFIX} /sensor9 >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr1WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-custom-app-producer /${PREFIX} /sensor10 >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr1WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-custom-app-producer /${PREFIX} /sensor11 >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr1WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-custom-app-producer /${PREFIX} /sensor12 >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr1WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-custom-app-producer /${PREFIX} /sensor13 >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr1WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-custom-app-producer /${PREFIX} /sensor14 >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr1WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-custom-app-producer /${PREFIX} /sensor15 >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr1WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-custom-app-producer /${PREFIX} /sensor16 >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr1WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-custom-app-producer /${PREFIX} /sensor17 >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr1WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-custom-app-producer /${PREFIX} /sensor18 >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr1WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-custom-app-producer /${PREFIX} /sensor19 >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr1WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-custom-app-producer /${PREFIX} /sensor20 >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${consumerWiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-dag-orchestratorA-app /${PREFIX} /serviceOrchestration >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr2WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceA-app /${PREFIX} /serviceP1 >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr2WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceA-app /${PREFIX} /serviceP2 >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr2WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceA-app /${PREFIX} /serviceP3 >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr2WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceA-app /${PREFIX} /serviceP4 >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr2WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceA-app /${PREFIX} /serviceP5 >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr2WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceA-app /${PREFIX} /serviceP6 >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr2WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceA-app /${PREFIX} /serviceP7 >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr2WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceA-app /${PREFIX} /serviceP8 >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr2WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceA-app /${PREFIX} /serviceP9 >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr2WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceA-app /${PREFIX} /serviceP10 >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr2WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceA-app /${PREFIX} /serviceP11 >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr2WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceA-app /${PREFIX} /serviceP12 >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr2WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceA-app /${PREFIX} /serviceP13 >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr2WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceA-app /${PREFIX} /serviceP14 >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr2WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceA-app /${PREFIX} /serviceP15 >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr2WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceA-app /${PREFIX} /serviceP16 >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr2WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceA-app /${PREFIX} /serviceP17 >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr2WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceA-app /${PREFIX} /serviceP18 >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr2WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceA-app /${PREFIX} /serviceP19 >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr2WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceA-app /${PREFIX} /serviceP20 >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr3WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceA-app /${PREFIX} /serviceP21 >/dev/null 2>&1 &"
	sleep 1
	sleep ${sleep}; ssh ${username}@${consumerWiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-custom-app-consumer /${PREFIX} ~/mini-ndn/workflows/20-sensor.json 1"
fi

if [ $run_20Sensor_OrchB ]; then
	sleep ${sleep}; ssh ${username}@${rtr1WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-custom-app-producer /${PREFIX} /sensor1 >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr1WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-custom-app-producer /${PREFIX} /sensor2 >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr1WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-custom-app-producer /${PREFIX} /sensor3 >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr1WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-custom-app-producer /${PREFIX} /sensor4 >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr1WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-custom-app-producer /${PREFIX} /sensor5 >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr1WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-custom-app-producer /${PREFIX} /sensor6 >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr1WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-custom-app-producer /${PREFIX} /sensor7 >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr1WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-custom-app-producer /${PREFIX} /sensor8 >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr1WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-custom-app-producer /${PREFIX} /sensor9 >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr1WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-custom-app-producer /${PREFIX} /sensor10 >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr1WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-custom-app-producer /${PREFIX} /sensor11 >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr1WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-custom-app-producer /${PREFIX} /sensor12 >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr1WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-custom-app-producer /${PREFIX} /sensor13 >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr1WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-custom-app-producer /${PREFIX} /sensor14 >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr1WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-custom-app-producer /${PREFIX} /sensor15 >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr1WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-custom-app-producer /${PREFIX} /sensor16 >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr1WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-custom-app-producer /${PREFIX} /sensor17 >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr1WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-custom-app-producer /${PREFIX} /sensor18 >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr1WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-custom-app-producer /${PREFIX} /sensor19 >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr1WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-custom-app-producer /${PREFIX} /sensor20 >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${consumerWiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-dag-orchestratorB-app /${PREFIX} /serviceOrchestration >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr2WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceB-app /${PREFIX} /serviceP1 >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr2WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceB-app /${PREFIX} /serviceP2 >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr2WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceB-app /${PREFIX} /serviceP3 >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr2WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceB-app /${PREFIX} /serviceP4 >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr2WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceB-app /${PREFIX} /serviceP5 >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr2WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceB-app /${PREFIX} /serviceP6 >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr2WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceB-app /${PREFIX} /serviceP7 >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr2WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceB-app /${PREFIX} /serviceP8 >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr2WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceB-app /${PREFIX} /serviceP9 >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr2WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceB-app /${PREFIX} /serviceP10 >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr2WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceB-app /${PREFIX} /serviceP11 >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr2WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceB-app /${PREFIX} /serviceP12 >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr2WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceB-app /${PREFIX} /serviceP13 >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr2WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceB-app /${PREFIX} /serviceP14 >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr2WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceB-app /${PREFIX} /serviceP15 >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr2WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceB-app /${PREFIX} /serviceP16 >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr2WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceB-app /${PREFIX} /serviceP17 >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr2WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceB-app /${PREFIX} /serviceP18 >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr2WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceB-app /${PREFIX} /serviceP19 >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr2WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceB-app /${PREFIX} /serviceP20 >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr3WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceB-app /${PREFIX} /serviceP21 >/dev/null 2>&1 &"
	sleep 1
	sleep ${sleep}; ssh ${username}@${consumerWiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-custom-app-consumer /${PREFIX} ~/mini-ndn/workflows/20-sensor.json 2"
fi

if [ $run_20Sensor_nesco ]; then
	sleep ${sleep}; ssh ${username}@${rtr1WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-custom-app-producer /${PREFIX} /sensor1 >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr1WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-custom-app-producer /${PREFIX} /sensor2 >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr1WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-custom-app-producer /${PREFIX} /sensor3 >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr1WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-custom-app-producer /${PREFIX} /sensor4 >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr1WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-custom-app-producer /${PREFIX} /sensor5 >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr1WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-custom-app-producer /${PREFIX} /sensor6 >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr1WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-custom-app-producer /${PREFIX} /sensor7 >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr1WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-custom-app-producer /${PREFIX} /sensor8 >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr1WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-custom-app-producer /${PREFIX} /sensor9 >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr1WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-custom-app-producer /${PREFIX} /sensor10 >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr1WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-custom-app-producer /${PREFIX} /sensor11 >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr1WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-custom-app-producer /${PREFIX} /sensor12 >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr1WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-custom-app-producer /${PREFIX} /sensor13 >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr1WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-custom-app-producer /${PREFIX} /sensor14 >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr1WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-custom-app-producer /${PREFIX} /sensor15 >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr1WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-custom-app-producer /${PREFIX} /sensor16 >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr1WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-custom-app-producer /${PREFIX} /sensor17 >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr1WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-custom-app-producer /${PREFIX} /sensor18 >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr1WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-custom-app-producer /${PREFIX} /sensor19 >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr1WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-custom-app-producer /${PREFIX} /sensor20 >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr2WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-dag-forwarder-app /${PREFIX} /serviceP1 >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr2WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-dag-forwarder-app /${PREFIX} /serviceP2 >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr2WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-dag-forwarder-app /${PREFIX} /serviceP3 >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr2WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-dag-forwarder-app /${PREFIX} /serviceP4 >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr2WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-dag-forwarder-app /${PREFIX} /serviceP5 >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr2WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-dag-forwarder-app /${PREFIX} /serviceP6 >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr2WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-dag-forwarder-app /${PREFIX} /serviceP7 >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr2WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-dag-forwarder-app /${PREFIX} /serviceP8 >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr2WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-dag-forwarder-app /${PREFIX} /serviceP9 >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr2WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-dag-forwarder-app /${PREFIX} /serviceP10 >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr2WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-dag-forwarder-app /${PREFIX} /serviceP11 >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr2WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-dag-forwarder-app /${PREFIX} /serviceP12 >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr2WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-dag-forwarder-app /${PREFIX} /serviceP13 >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr2WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-dag-forwarder-app /${PREFIX} /serviceP14 >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr2WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-dag-forwarder-app /${PREFIX} /serviceP15 >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr2WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-dag-forwarder-app /${PREFIX} /serviceP16 >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr2WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-dag-forwarder-app /${PREFIX} /serviceP17 >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr2WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-dag-forwarder-app /${PREFIX} /serviceP18 >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr2WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-dag-forwarder-app /${PREFIX} /serviceP19 >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr2WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-dag-forwarder-app /${PREFIX} /serviceP20 >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr3WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-dag-forwarder-app /${PREFIX} /serviceP21 >/dev/null 2>&1 &"
	sleep 1
	sleep ${sleep}; ssh ${username}@${consumerWiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-custom-app-consumer /${PREFIX} ~/mini-ndn/workflows/20-sensor.json 0"
fi

if [ $run_20Linear_OrchA ]; then
	sleep ${sleep}; ssh ${username}@${producerWiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-custom-app-producer /${PREFIX} /sensor >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${consumerWiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-dag-orchestratorA-app /${PREFIX} /serviceOrchestration >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr2WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceA-app /${PREFIX} /serviceL1 >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr1WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceA-app /${PREFIX} /serviceL2 >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr2WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceA-app /${PREFIX} /serviceL3 >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr3WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceA-app /${PREFIX} /serviceL4 >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr2WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceA-app /${PREFIX} /serviceL5 >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr1WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceA-app /${PREFIX} /serviceL6 >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr2WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceA-app /${PREFIX} /serviceL7 >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr3WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceA-app /${PREFIX} /serviceL8 >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr2WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceA-app /${PREFIX} /serviceL9 >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr1WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceA-app /${PREFIX} /serviceL10 >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr2WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceA-app /${PREFIX} /serviceL11 >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr3WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceA-app /${PREFIX} /serviceL12 >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr2WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceA-app /${PREFIX} /serviceL13 >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr1WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceA-app /${PREFIX} /serviceL14 >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr2WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceA-app /${PREFIX} /serviceL15 >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr3WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceA-app /${PREFIX} /serviceL16 >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr2WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceA-app /${PREFIX} /serviceL17 >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr1WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceA-app /${PREFIX} /serviceL18 >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr2WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceA-app /${PREFIX} /serviceL19 >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr3WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceA-app /${PREFIX} /serviceL20 >/dev/null 2>&1 &"
	sleep 1
	sleep ${sleep}; ssh ${username}@${consumerWiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-custom-app-consumer /${PREFIX} ~/mini-ndn/workflows/20-linear.json 1"
fi

if [ $run_20Linear_OrchB ]; then
	sleep ${sleep}; ssh ${username}@${producerWiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-custom-app-producer /${PREFIX} /sensor >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${consumerWiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-dag-orchestratorB-app /${PREFIX} /serviceOrchestration >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr2WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceB-app /${PREFIX} /serviceL1 >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr1WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceB-app /${PREFIX} /serviceL2 >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr2WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceB-app /${PREFIX} /serviceL3 >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr3WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceB-app /${PREFIX} /serviceL4 >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr2WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceB-app /${PREFIX} /serviceL5 >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr1WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceB-app /${PREFIX} /serviceL6 >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr2WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceB-app /${PREFIX} /serviceL7 >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr3WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceB-app /${PREFIX} /serviceL8 >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr2WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceB-app /${PREFIX} /serviceL9 >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr1WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceB-app /${PREFIX} /serviceL10 >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr2WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceB-app /${PREFIX} /serviceL11 >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr3WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceB-app /${PREFIX} /serviceL12 >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr2WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceB-app /${PREFIX} /serviceL13 >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr1WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceB-app /${PREFIX} /serviceL14 >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr2WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceB-app /${PREFIX} /serviceL15 >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr3WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceB-app /${PREFIX} /serviceL16 >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr2WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceB-app /${PREFIX} /serviceL17 >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr1WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceB-app /${PREFIX} /serviceL18 >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr2WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceB-app /${PREFIX} /serviceL19 >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr3WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceB-app /${PREFIX} /serviceL20 >/dev/null 2>&1 &"
	sleep 1
	sleep ${sleep}; ssh ${username}@${consumerWiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-custom-app-consumer /${PREFIX} ~/mini-ndn/workflows/20-linear.json 2"
fi

if [ $run_20Linear_nesco ]; then
	sleep ${sleep}; ssh ${username}@${producerWiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-custom-app-producer /${PREFIX} /sensor >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr2WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-dag-forwarder-app /${PREFIX} /serviceL1 >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr1WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-dag-forwarder-app /${PREFIX} /serviceL2 >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr2WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-dag-forwarder-app /${PREFIX} /serviceL3 >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr3WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-dag-forwarder-app /${PREFIX} /serviceL4 >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr2WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-dag-forwarder-app /${PREFIX} /serviceL5 >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr1WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-dag-forwarder-app /${PREFIX} /serviceL6 >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr2WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-dag-forwarder-app /${PREFIX} /serviceL7 >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr3WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-dag-forwarder-app /${PREFIX} /serviceL8 >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr2WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-dag-forwarder-app /${PREFIX} /serviceL9 >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr1WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-dag-forwarder-app /${PREFIX} /serviceL10 >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr2WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-dag-forwarder-app /${PREFIX} /serviceL11 >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr3WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-dag-forwarder-app /${PREFIX} /serviceL12 >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr2WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-dag-forwarder-app /${PREFIX} /serviceL13 >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr1WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-dag-forwarder-app /${PREFIX} /serviceL14 >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr2WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-dag-forwarder-app /${PREFIX} /serviceL15 >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr3WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-dag-forwarder-app /${PREFIX} /serviceL16 >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr2WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-dag-forwarder-app /${PREFIX} /serviceL17 >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr1WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-dag-forwarder-app /${PREFIX} /serviceL18 >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr2WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-dag-forwarder-app /${PREFIX} /serviceL19 >/dev/null 2>&1 &"
	sleep ${sleep}; ssh ${username}@${rtr3WiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-dag-forwarder-app /${PREFIX} /serviceL20 >/dev/null 2>&1 &"
	sleep 1
	sleep ${sleep}; ssh ${username}@${consumerWiFiIP} "~/ndn/ndn-cxx/build/examples/cabeee-custom-app-consumer /${PREFIX} ~/mini-ndn/workflows/20-linear.json 0"
fi












# stop NFD on all devices to clear caches and forwarding table entries
#ssh ${username}@${consumerWiFiIP} "nfd-stop >/dev/null 2>&1 &"
#ssh ${username}@${rtr3WiFiIP} "nfd-stop >/dev/null 2>&1 &"
#ssh ${username}@${rtr2WiFiIP} "nfd-stop >/dev/null 2>&1 &"
#ssh ${username}@${rtr1WiFiIP} "nfd-stop >/dev/null 2>&1 &"
#ssh ${username}@${producerWiFiIP} "nfd-stop >/dev/null 2>&1 &"



