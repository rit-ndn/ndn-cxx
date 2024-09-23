#! /bin/bash



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




device=$1
scenario=$2
PREFIX=$3
sleepVal=$4



# stop NFD to clear cache and forwarding table entries
#nfd-stop &
nfd-stop >/dev/null 2>&1 &

sleep 1

# start NFD
#nfd-start &
nfd-start >/dev/null 2>&1 &

sleep 1


# create the faces
if [ ${device} == producer ]; then
	echo -e "Creating faces for the producer\n"
	sleep ${sleepVal}; nfdc face create remote ether://[${rtr1ETHMAC}] local dev://${producerETHinterface} persistency permanent
fi
if [ ${device} == rtr1 ]; then
	echo -e "Creating faces for rtr1\n"
	sleep ${sleepVal}; nfdc face create remote ether://[${producerETHMAC}] local dev://${rtr1ETHinterface} persistency permanent
	sleep ${sleepVal}; nfdc face create remote ether://[${rtr2ETHMAC}] local dev://${rtr1ETHinterface} persistency permanent
fi
if [ ${device} == rtr2 ]; then
	echo -e "Creating faces for rtr2\n"
	sleep ${sleepVal}; nfdc face create remote ether://[${rtr1ETHMAC}] local dev://${rtr2ETHinterface} persistency permanent
	sleep ${sleepVal}; nfdc face create remote ether://[${rtr3ETHMAC}] local dev://${rtr2ETHinterface} persistency permanent
fi
if [ ${device} == rtr3 ]; then
	echo -e "Creating faces for rtr3\n"
	sleep ${sleepVal}; nfdc face create remote ether://[${rtr2ETHMAC}] local dev://${rtr3ETHinterface} persistency permanent
	sleep ${sleepVal}; nfdc face create remote ether://[${consumerETHMAC}] local dev://${rtr3ETHinterface} persistency permanent
fi
if [ ${device} == consumer ]; then
	echo -e "Creating faces for the consumer\n"
	sleep ${sleepVal}; nfdc face create remote ether://[${rtr3ETHMAC}] local dev://${consumerETHinterface} persistency permanent
fi




# add routes for all the PREFIXes to all nodes
if [ ${scenario} == run_4DAG_OrchA ] || [ ${scenario} == run_4DAG_OrchB ] || [ ${scenario} == run_4DAG_nesco ] || [ ${scenario} == run_8DAG_OrchA ] || [ ${scenario} == run_8DAG_OrchB ] || [ ${scenario} == run_8DAG_nesco ] || [ ${scenario} == run_8DAG_Caching_OrchA ] || [ ${scenario} == run_8DAG_Caching_OrchB ] || [ ${scenario} == run_8DAG_Caching_nesco ]; then
	echo -e "4DAG or 8DAG scenario"
	if [ ${device} == consumer ]; then
		echo -e "Setting up routes for the consumer\n"
		sleep ${sleepVal}; nfdc route add /${PREFIX} ether://[${rtr3ETHMAC}]
	fi
	
	if [ ${device} == rtr3 ]; then
		echo -e "Setting up routes for rtr3\n"
		sleep ${sleepVal}; nfdc route add /${PREFIX} ether://[${rtr3ETHMAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/sensor ether://[${rtr2ETHMAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/service2 ether://[${rtr2ETHMAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/service3 ether://[${rtr2ETHMAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/service4 ether://[${rtr2ETHMAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/service6 ether://[${rtr2ETHMAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/service7 ether://[${rtr2ETHMAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/service8 ether://[${rtr2ETHMAC}]
	fi

	if [ ${device} == rtr2 ]; then
		echo -e "Setting up routes for rtr2\n"
		sleep ${sleepVal}; nfdc route add /${PREFIX} ether://[${rtr2ETHMAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/sensor ether://[${rtr1ETHMAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/service2 ether://[${rtr1ETHMAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/service1 ether://[${rtr3ETHMAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/service6 ether://[${rtr1ETHMAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/service5 ether://[${rtr3ETHMAC}]
	fi

	if [ ${device} == rtr1 ]; then
		echo -e "Setting up routes for rtr1\n"
		sleep ${sleepVal}; nfdc route add /${PREFIX} ether://[${rtr1ETHMAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/sensor ether://[${producerETHMAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/service1 ether://[${rtr2ETHMAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/service3 ether://[${rtr2ETHMAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/service4 ether://[${rtr2ETHMAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/service5 ether://[${rtr2ETHMAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/service7 ether://[${rtr2ETHMAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/service8 ether://[${rtr2ETHMAC}]
	fi

	if [ ${device} == producer ]; then
		echo -e "Setting up routes for rtr3\n"
		sleep ${sleepVal}; nfdc route add /${PREFIX} ether://[${producerETHMAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/service1 ether://[${rtr1ETHMAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/service2 ether://[${rtr1ETHMAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/service3 ether://[${rtr1ETHMAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/service4 ether://[${rtr1ETHMAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/service5 ether://[${rtr1ETHMAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/service6 ether://[${rtr1ETHMAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/service7 ether://[${rtr1ETHMAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/service8 ether://[${rtr1ETHMAC}]
	fi
fi

if [ ${scenario} == run_20Parallel_OrchA ] || [ ${scenario} == run_20Parallel_OrchB ] || [ ${scenario} == run_20Parallel_nesco ]; then
	echo -e "20Parallel scenario"
	if [ ${device} == consumer ]; then
		echo -e "Setting up routes for the consumer\n"
		sleep ${sleepVal}; nfdc route add /${PREFIX} ether://[${rtr3ETHMAC}]
	fi
	if [ ${device} == rtr3 ]; then
		echo -e "Setting up routes for rtr3\n"
		sleep ${sleepVal}; nfdc route add /${PREFIX} ether://[${rtr3ETHMAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/sensor ether://[${rtr2ETHMAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceP1 ether://[${rtr2ETHMAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceP2 ether://[${rtr2ETHMAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceP3 ether://[${rtr2ETHMAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceP4 ether://[${rtr2ETHMAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceP5 ether://[${rtr2ETHMAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceP6 ether://[${rtr2ETHMAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceP7 ether://[${rtr2ETHMAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceP8 ether://[${rtr2ETHMAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceP9 ether://[${rtr2ETHMAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceP10 ether://[${rtr2ETHMAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceP11 ether://[${rtr2ETHMAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceP12 ether://[${rtr2ETHMAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceP13 ether://[${rtr2ETHMAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceP14 ether://[${rtr2ETHMAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceP15 ether://[${rtr2ETHMAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceP16 ether://[${rtr2ETHMAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceP17 ether://[${rtr2ETHMAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceP18 ether://[${rtr2ETHMAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceP19 ether://[${rtr2ETHMAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceP20 ether://[${rtr2ETHMAC}]
	fi
	if [ ${device} == rtr2 ]; then
		echo -e "Setting up routes for rtr2\n"
		sleep ${sleepVal}; nfdc route add /${PREFIX}/sensor ether://[${rtr1ETHMAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceP21 ether://[${rtr3ETHMAC}]
	fi
	if [ ${device} == rtr1 ]; then
		echo -e "Setting up routes for rtr1\n"
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceP1 ether://[${rtr2ETHMAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceP2 ether://[${rtr2ETHMAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceP3 ether://[${rtr2ETHMAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceP4 ether://[${rtr2ETHMAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceP5 ether://[${rtr2ETHMAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceP6 ether://[${rtr2ETHMAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceP7 ether://[${rtr2ETHMAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceP8 ether://[${rtr2ETHMAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceP9 ether://[${rtr2ETHMAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceP10 ether://[${rtr2ETHMAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceP11 ether://[${rtr2ETHMAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceP12 ether://[${rtr2ETHMAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceP13 ether://[${rtr2ETHMAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceP14 ether://[${rtr2ETHMAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceP15 ether://[${rtr2ETHMAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceP16 ether://[${rtr2ETHMAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceP17 ether://[${rtr2ETHMAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceP18 ether://[${rtr2ETHMAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceP19 ether://[${rtr2ETHMAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceP20 ether://[${rtr2ETHMAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceP21 ether://[${rtr2ETHMAC}]
	fi
	


fi

if [ ${scenario} == run_20Sensor_OrchA ] || [ ${scenario} == run_20Sensor_OrchB ] || [ ${scenario} == run_20Sensor_nesco ]; then
	if [ ${device} == consumer ]; then
		sleep ${sleepVal}; nfdc route add /${PREFIX} ether://[${rtr3ETHMAC}]
	fi
	if [ ${device} == rtr3 ]; then
		sleep ${sleepVal}; nfdc route add /${PREFIX} ether://[${rtr3ETHMAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/sensor1 ether://[${rtr2ETHMAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/sensor2 ether://[${rtr2ETHMAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/sensor3 ether://[${rtr2ETHMAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/sensor4 ether://[${rtr2ETHMAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/sensor5 ether://[${rtr2ETHMAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/sensor6 ether://[${rtr2ETHMAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/sensor7 ether://[${rtr2ETHMAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/sensor8 ether://[${rtr2ETHMAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/sensor9 ether://[${rtr2ETHMAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/sensor10 ether://[${rtr2ETHMAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/sensor11 ether://[${rtr2ETHMAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/sensor12 ether://[${rtr2ETHMAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/sensor13 ether://[${rtr2ETHMAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/sensor14 ether://[${rtr2ETHMAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/sensor15 ether://[${rtr2ETHMAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/sensor16 ether://[${rtr2ETHMAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/sensor17 ether://[${rtr2ETHMAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/sensor18 ether://[${rtr2ETHMAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/sensor19 ether://[${rtr2ETHMAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/sensor20 ether://[${rtr2ETHMAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceP1 ether://[${rtr2ETHMAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceP2 ether://[${rtr2ETHMAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceP3 ether://[${rtr2ETHMAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceP4 ether://[${rtr2ETHMAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceP5 ether://[${rtr2ETHMAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceP6 ether://[${rtr2ETHMAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceP7 ether://[${rtr2ETHMAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceP8 ether://[${rtr2ETHMAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceP9 ether://[${rtr2ETHMAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceP10 ether://[${rtr2ETHMAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceP11 ether://[${rtr2ETHMAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceP12 ether://[${rtr2ETHMAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceP13 ether://[${rtr2ETHMAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceP14 ether://[${rtr2ETHMAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceP15 ether://[${rtr2ETHMAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceP16 ether://[${rtr2ETHMAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceP17 ether://[${rtr2ETHMAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceP18 ether://[${rtr2ETHMAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceP19 ether://[${rtr2ETHMAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceP20 ether://[${rtr2ETHMAC}]
	fi
	if [ ${device} == rtr2 ]; then
		sleep ${sleepVal}; nfdc route add /${PREFIX}/sensor1 ether://[${rtr1ETHMAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/sensor2 ether://[${rtr1ETHMAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/sensor3 ether://[${rtr1ETHMAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/sensor4 ether://[${rtr1ETHMAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/sensor5 ether://[${rtr1ETHMAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/sensor6 ether://[${rtr1ETHMAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/sensor7 ether://[${rtr1ETHMAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/sensor8 ether://[${rtr1ETHMAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/sensor9 ether://[${rtr1ETHMAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/sensor10 ether://[${rtr1ETHMAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/sensor11 ether://[${rtr1ETHMAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/sensor12 ether://[${rtr1ETHMAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/sensor13 ether://[${rtr1ETHMAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/sensor14 ether://[${rtr1ETHMAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/sensor15 ether://[${rtr1ETHMAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/sensor16 ether://[${rtr1ETHMAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/sensor17 ether://[${rtr1ETHMAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/sensor18 ether://[${rtr1ETHMAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/sensor19 ether://[${rtr1ETHMAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/sensor20 ether://[${rtr1ETHMAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceP21 ether://[${rtr3ETHMAC}]
	fi
	if [ ${device} == rtr1 ]; then
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceP1 ether://[${rtr2ETHMAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceP2 ether://[${rtr2ETHMAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceP3 ether://[${rtr2ETHMAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceP4 ether://[${rtr2ETHMAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceP5 ether://[${rtr2ETHMAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceP6 ether://[${rtr2ETHMAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceP7 ether://[${rtr2ETHMAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceP8 ether://[${rtr2ETHMAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceP9 ether://[${rtr2ETHMAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceP10 ether://[${rtr2ETHMAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceP11 ether://[${rtr2ETHMAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceP12 ether://[${rtr2ETHMAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceP13 ether://[${rtr2ETHMAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceP14 ether://[${rtr2ETHMAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceP15 ether://[${rtr2ETHMAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceP16 ether://[${rtr2ETHMAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceP17 ether://[${rtr2ETHMAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceP18 ether://[${rtr2ETHMAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceP19 ether://[${rtr2ETHMAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceP20 ether://[${rtr2ETHMAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceP21 ether://[${rtr2ETHMAC}]
	fi
		


fi

if [ ${scenario} == run_20Linear_OrchA ] || [ ${scenario} == run_20Linear_OrchB ] || [ ${scenario} == run_20Linear_nesco ]; then
	if [ ${device} == consumer ]; then
		sleep ${sleepVal}; nfdc route add /${PREFIX} ether://[${rtr3ETHMAC}]
	fi
	if [ ${device} == rtr3 ]; then
		sleep ${sleepVal}; nfdc route add /${PREFIX} ether://[${rtr3ETHMAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/sensor ether://[${rtr2ETHMAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceL1 ether://[${rtr2ETHMAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceL3 ether://[${rtr2ETHMAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceL5 ether://[${rtr2ETHMAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceL7 ether://[${rtr2ETHMAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceL9 ether://[${rtr2ETHMAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceL11 ether://[${rtr2ETHMAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceL13 ether://[${rtr2ETHMAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceL15 ether://[${rtr2ETHMAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceL17 ether://[${rtr2ETHMAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceL19 ether://[${rtr2ETHMAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceL2 ether://[${rtr2ETHMAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceL6 ether://[${rtr2ETHMAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceL10 ether://[${rtr2ETHMAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceL14 ether://[${rtr2ETHMAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceL18 ether://[${rtr2ETHMAC}]
	fi
	if [ ${device} == rtr2 ]; then
		sleep ${sleepVal}; nfdc route add /${PREFIX} ether://[${rtr2ETHMAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/sensor ether://[${rtr1ETHMAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceL4 ether://[${rtr3ETHMAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceL8 ether://[${rtr3ETHMAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceL12 ether://[${rtr3ETHMAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceL16 ether://[${rtr3ETHMAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceL20 ether://[${rtr3ETHMAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceL2 ether://[${rtr1ETHMAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceL6 ether://[${rtr1ETHMAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceL10 ether://[${rtr1ETHMAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceL14 ether://[${rtr1ETHMAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceL18 ether://[${rtr1ETHMAC}]

	fi
	if [ ${device} == rtr1 ]; then
		sleep ${sleepVal}; nfdc route add /${PREFIX} ether://[${rtr1ETHMAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/sensor ether://[${producerETHMAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceL1 ether://[${rtr2ETHMAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceL3 ether://[${rtr2ETHMAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceL5 ether://[${rtr2ETHMAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceL7 ether://[${rtr2ETHMAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceL9 ether://[${rtr2ETHMAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceL11 ether://[${rtr2ETHMAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceL13 ether://[${rtr2ETHMAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceL15 ether://[${rtr2ETHMAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceL17 ether://[${rtr2ETHMAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceL19 ether://[${rtr2ETHMAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceL4 ether://[${rtr2ETHMAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceL8 ether://[${rtr2ETHMAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceL12 ether://[${rtr2ETHMAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceL16 ether://[${rtr2ETHMAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceL20 ether://[${rtr2ETHMAC}]
	fi
	if [ ${device} == producer ]; then
		sleep ${sleepVal}; nfdc route add /${PREFIX} ether://[${producerETHMAC}]
		#sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceL1 ether://[${rtr1ETHMAC}]
		#sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceL2 ether://[${rtr1ETHMAC}]
		#sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceL3 ether://[${rtr1ETHMAC}]
		#sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceL4 ether://[${rtr1ETHMAC}]
		#sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceL5 ether://[${rtr1ETHMAC}]
		#sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceL6 ether://[${rtr1ETHMAC}]
		#sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceL7 ether://[${rtr1ETHMAC}]
		#sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceL8 ether://[${rtr1ETHMAC}]
		#sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceL9 ether://[${rtr1ETHMAC}]
		#sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceL10 ether://[${rtr1ETHMAC}]
		#sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceL11 ether://[${rtr1ETHMAC}]
		#sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceL12 ether://[${rtr1ETHMAC}]
		#sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceL13 ether://[${rtr1ETHMAC}]
		#sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceL14 ether://[${rtr1ETHMAC}]
		#sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceL15 ether://[${rtr1ETHMAC}]
		#sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceL16 ether://[${rtr1ETHMAC}]
		#sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceL17 ether://[${rtr1ETHMAC}]
		#sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceL18 ether://[${rtr1ETHMAC}]
		#sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceL19 ether://[${rtr1ETHMAC}]
		#sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceL20 ether://[${rtr1ETHMAC}]
	fi
fi




sleep 1




if [ ${scenario} == run_4DAG_OrchA ]; then
	if [ ${device} == producer ]; then
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-custom-app-producer /${PREFIX} /sensor &
	fi
	if [ ${device} == rtr1 ]; then
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceA-app /${PREFIX} /service2 &
	fi
	if [ ${device} == rtr2 ]; then
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceA-app /${PREFIX} /service3 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceA-app /${PREFIX} /service4 &
	fi
	if [ ${device} == rtr3 ]; then
		# start forwarder application(s)
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceA-app /${PREFIX} /service1 &
	fi
	if [ ${device} == consumer ]; then
		# start orchestratorA application
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-orchestratorA-app /${PREFIX} /serviceOrchestration &
		sleep 1
		# start consumer application (not in the background, so that we see the final print statements)
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-custom-app-consumer /${PREFIX} ~/mini-ndn/workflows/4dag.json 1
	fi
fi

if [ ${scenario} == run_4DAG_OrchB ]; then
	if [ ${device} == producer ]; then
		# start producer application
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-custom-app-producer /${PREFIX} /sensor &
	fi
	if [ ${device} == rtr1 ]; then
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceB-app /${PREFIX} /service2 &
	fi
	if [ ${device} == rtr2 ]; then
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceB-app /${PREFIX} /service3 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceB-app /${PREFIX} /service4 &
	fi
	if [ ${device} == rtr3 ]; then
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceB-app /${PREFIX} /service1 &
	fi
	if [ ${device} == consumer ]; then
		# start orchestratorA application
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-orchestratorB-app /${PREFIX} /serviceOrchestration &
		sleep 1
		# start consumer application (not in the background, so that we see the final print statements)
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-custom-app-consumer /${PREFIX} ~/mini-ndn/workflows/4dag.json 2
	fi
fi

if [ ${scenario} == run_4DAG_nesco ]; then
	if [ ${device} == producer ]; then
		# start producer application
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-custom-app-producer /${PREFIX} /sensor &
	fi
	if [ ${device} == rtr1 ]; then
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-forwarder-app /${PREFIX} /service2 &
	fi
	if [ ${device} == rtr2 ]; then
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-forwarder-app /${PREFIX} /service3 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-forwarder-app /${PREFIX} /service4 &
	fi
	if [ ${device} == rtr3 ]; then
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-forwarder-app /${PREFIX} /service1 &
	fi
	if [ ${device} == consumer ]; then
		sleep 1
		# start consumer application (not in the background, so that we see the final print statements)
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-custom-app-consumer /${PREFIX} ~/mini-ndn/workflows/4dag.json 0
	fi
fi

if [ ${scenario} == run_8DAG_OrchA ]; then
	if [ ${device} == producer ]; then
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-custom-app-producer /${PREFIX} /sensor &
	fi
	if [ ${device} == rtr1 ]; then
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceA-app /${PREFIX} /service2 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceA-app /${PREFIX} /service6 &
	fi
	if [ ${device} == rtr2 ]; then
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceA-app /${PREFIX} /service3 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceA-app /${PREFIX} /service4 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceA-app /${PREFIX} /service7 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceA-app /${PREFIX} /service8 &
	fi
	if [ ${device} == rtr3 ]; then
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceA-app /${PREFIX} /service1 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceA-app /${PREFIX} /service5 &
	fi
	if [ ${device} == consumer ]; then
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-orchestratorA-app /${PREFIX} /serviceOrchestration &
		sleep 1
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-custom-app-consumer2 /${PREFIX} ~/mini-ndn/workflows/8dag.json 1
	fi
fi

if [ ${scenario} == run_8DAG_OrchB ]; then
	if [ ${device} == producer ]; then
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-custom-app-producer /${PREFIX} /sensor &
	fi
	if [ ${device} == rtr1 ]; then
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceB-app /${PREFIX} /service2 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceB-app /${PREFIX} /service6 &
	fi
	if [ ${device} == rtr2 ]; then
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceB-app /${PREFIX} /service3 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceB-app /${PREFIX} /service4 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceB-app /${PREFIX} /service7 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceB-app /${PREFIX} /service8 &
	fi
	if [ ${device} == rtr3 ]; then
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceB-app /${PREFIX} /service1 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceB-app /${PREFIX} /service5 &
	fi
	if [ ${device} == consumer ]; then
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-orchestratorB-app /${PREFIX} /serviceOrchestration &
		sleep 1
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-custom-app-consumer2 /${PREFIX} ~/mini-ndn/workflows/8dag.json 2
	fi

fi

if [ ${scenario} == run_8DAG_nesco ]; then
	if [ ${device} == producer ]; then
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-custom-app-producer /${PREFIX} /sensor &
	fi
	if [ ${device} == rtr1 ]; then
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-forwarder-app /${PREFIX} /service2 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-forwarder-app /${PREFIX} /service6 &
	fi
	if [ ${device} == rtr2 ]; then
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-forwarder-app /${PREFIX} /service3 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-forwarder-app /${PREFIX} /service4 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-forwarder-app /${PREFIX} /service7 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-forwarder-app /${PREFIX} /service8 &
	fi
	if [ ${device} == rtr3 ]; then
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-forwarder-app /${PREFIX} /service1 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-forwarder-app /${PREFIX} /service5 &
	fi
	if [ ${device} == consumer ]; then
		sleep 1
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-custom-app-consumer2 /${PREFIX} ~/mini-ndn/workflows/8dag.json 0
	fi
fi

if [ ${scenario} == run_8DAG_Caching_OrchA ]; then
	if [ ${device} == producer ]; then
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-custom-app-producer /${PREFIX} /sensor &
	fi
	if [ ${device} == rtr1 ]; then
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceA-app /${PREFIX} /service2 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceA-app /${PREFIX} /service6 &
	fi
	if [ ${device} == rtr2 ]; then
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceA-app /${PREFIX} /service3 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceA-app /${PREFIX} /service4 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceA-app /${PREFIX} /service7 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceA-app /${PREFIX} /service8 &
	fi
	if [ ${device} == rtr3 ]; then
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceA-app /${PREFIX} /service1 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceA-app /${PREFIX} /service5 &
	fi
	if [ ${device} == consumer ]; then
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-orchestratorA-app /${PREFIX} /serviceOrchestration &
		sleep 1
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-custom-app-consumer /${PREFIX} ~/mini-ndn/workflows/4dag.json 1
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-orchestratorA-reset-app /${PREFIX} /serviceOrchestration/reset &
		sleep 1
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-custom-app-consumer2 /${PREFIX} ~/mini-ndn/workflows/8dag.json 1
	fi
fi

if [ ${scenario} == run_8DAG_Caching_OrchB ]; then
	if [ ${device} == producer ]; then
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-custom-app-producer /${PREFIX} /sensor &
	fi
	if [ ${device} == rtr1 ]; then
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceB-app /${PREFIX} /service2 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceB-app /${PREFIX} /service6 &
	fi
	if [ ${device} == rtr2 ]; then
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceB-app /${PREFIX} /service3 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceB-app /${PREFIX} /service4 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceB-app /${PREFIX} /service7 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceB-app /${PREFIX} /service8 &
	fi
	if [ ${device} == rtr3 ]; then
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceB-app /${PREFIX} /service1 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceB-app /${PREFIX} /service5 &
	fi
	if [ ${device} == consumer ]; then
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-orchestratorB-app /${PREFIX} /serviceOrchestration &
		sleep 1
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-custom-app-consumer /${PREFIX} ~/mini-ndn/workflows/4dag.json 2
		sleep 1
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-orchestratorA-reset-app /${PREFIX} /serviceOrchestration/reset &
		sleep 1
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-custom-app-consumer2 /${PREFIX} ~/mini-ndn/workflows/8dag.json 2
	fi
fi

if [ ${scenario} == run_8DAG_Caching_nesco ]; then
	if [ ${device} == producer ]; then
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-custom-app-producer /${PREFIX} /sensor &
	fi
	if [ ${device} == rtr1 ]; then
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-forwarder-app /${PREFIX} /service2 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-forwarder-app /${PREFIX} /service6 &
	fi
	if [ ${device} == rtr2 ]; then
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-forwarder-app /${PREFIX} /service3 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-forwarder-app /${PREFIX} /service4 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-forwarder-app /${PREFIX} /service7 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-forwarder-app /${PREFIX} /service8 &
	fi
	if [ ${device} == rtr3 ]; then
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-forwarder-app /${PREFIX} /service1 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-forwarder-app /${PREFIX} /service5 &
	fi
	if [ ${device} == consumer ]; then
		sleep 1
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-custom-app-consumer /${PREFIX} ~/mini-ndn/workflows/4dag.json 0
		sleep 1
		sleep 1
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-custom-app-consumer2 /${PREFIX} ~/mini-ndn/workflows/8dag.json 0
	fi
fi

if [ ${scenario} == run_20Parallel_OrchA ]; then
	if [ ${device} == rtr1 ]; then
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-custom-app-producer /${PREFIX} /sensor &
	fi
	if [ ${device} == rtr2 ]; then
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceA-app /${PREFIX} /serviceP1 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceA-app /${PREFIX} /serviceP2 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceA-app /${PREFIX} /serviceP3 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceA-app /${PREFIX} /serviceP4 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceA-app /${PREFIX} /serviceP5 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceA-app /${PREFIX} /serviceP6 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceA-app /${PREFIX} /serviceP7 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceA-app /${PREFIX} /serviceP8 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceA-app /${PREFIX} /serviceP9 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceA-app /${PREFIX} /serviceP10 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceA-app /${PREFIX} /serviceP11 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceA-app /${PREFIX} /serviceP12 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceA-app /${PREFIX} /serviceP13 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceA-app /${PREFIX} /serviceP14 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceA-app /${PREFIX} /serviceP15 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceA-app /${PREFIX} /serviceP16 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceA-app /${PREFIX} /serviceP17 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceA-app /${PREFIX} /serviceP18 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceA-app /${PREFIX} /serviceP19 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceA-app /${PREFIX} /serviceP20 &
	fi
	if [ ${device} == rtr3 ]; then
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceA-app /${PREFIX} /serviceP21 &
	fi
	if [ ${device} == consumer ]; then
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-orchestratorA-app /${PREFIX} /serviceOrchestration &
		sleep 1
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-custom-app-consumer /${PREFIX} ~/mini-ndn/workflows/20-parallel.json 1
	fi
fi

if [ ${scenario} == run_20Parallel_OrchB ]; then
	if [ ${device} == rtr1 ]; then
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-custom-app-producer /${PREFIX} /sensor &
	fi
	if [ ${device} == rtr2 ]; then
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceB-app /${PREFIX} /serviceP1 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceB-app /${PREFIX} /serviceP2 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceB-app /${PREFIX} /serviceP3 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceB-app /${PREFIX} /serviceP4 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceB-app /${PREFIX} /serviceP5 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceB-app /${PREFIX} /serviceP6 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceB-app /${PREFIX} /serviceP7 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceB-app /${PREFIX} /serviceP8 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceB-app /${PREFIX} /serviceP9 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceB-app /${PREFIX} /serviceP10 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceB-app /${PREFIX} /serviceP11 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceB-app /${PREFIX} /serviceP12 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceB-app /${PREFIX} /serviceP13 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceB-app /${PREFIX} /serviceP14 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceB-app /${PREFIX} /serviceP15 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceB-app /${PREFIX} /serviceP16 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceB-app /${PREFIX} /serviceP17 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceB-app /${PREFIX} /serviceP18 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceB-app /${PREFIX} /serviceP19 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceB-app /${PREFIX} /serviceP20 &
	fi
	if [ ${device} == rtr3 ]; then
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceB-app /${PREFIX} /serviceP21 &
	fi
	if [ ${device} == consumer ]; then
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-orchestratorB-app /${PREFIX} /serviceOrchestration &
		sleep 1
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-custom-app-consumer /${PREFIX} ~/mini-ndn/workflows/20-parallel.json 2
	fi
fi

if [ ${scenario} == run_20Parallel_nesco ]; then
	if [ ${device} == rtr1 ]; then
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-custom-app-producer /${PREFIX} /sensor &
	fi
	if [ ${device} == rtr2 ]; then
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-forwarder-app /${PREFIX} /serviceP1 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-forwarder-app /${PREFIX} /serviceP2 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-forwarder-app /${PREFIX} /serviceP3 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-forwarder-app /${PREFIX} /serviceP4 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-forwarder-app /${PREFIX} /serviceP5 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-forwarder-app /${PREFIX} /serviceP6 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-forwarder-app /${PREFIX} /serviceP7 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-forwarder-app /${PREFIX} /serviceP8 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-forwarder-app /${PREFIX} /serviceP9 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-forwarder-app /${PREFIX} /serviceP10 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-forwarder-app /${PREFIX} /serviceP11 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-forwarder-app /${PREFIX} /serviceP12 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-forwarder-app /${PREFIX} /serviceP13 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-forwarder-app /${PREFIX} /serviceP14 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-forwarder-app /${PREFIX} /serviceP15 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-forwarder-app /${PREFIX} /serviceP16 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-forwarder-app /${PREFIX} /serviceP17 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-forwarder-app /${PREFIX} /serviceP18 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-forwarder-app /${PREFIX} /serviceP19 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-forwarder-app /${PREFIX} /serviceP20 &
	fi
	if [ ${device} == rtr3 ]; then
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-forwarder-app /${PREFIX} /serviceP21 &
	fi
	if [ ${device} == consumer ]; then
		sleep 1
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-custom-app-consumer /${PREFIX} ~/mini-ndn/workflows/20-parallel.json 0
	fi
fi

if [ ${scenario} == run_20Sensor_OrchA ]; then
	if [ ${device} == rtr1 ]; then
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-custom-app-producer /${PREFIX} /sensor1 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-custom-app-producer /${PREFIX} /sensor2 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-custom-app-producer /${PREFIX} /sensor3 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-custom-app-producer /${PREFIX} /sensor4 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-custom-app-producer /${PREFIX} /sensor5 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-custom-app-producer /${PREFIX} /sensor6 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-custom-app-producer /${PREFIX} /sensor7 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-custom-app-producer /${PREFIX} /sensor8 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-custom-app-producer /${PREFIX} /sensor9 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-custom-app-producer /${PREFIX} /sensor10 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-custom-app-producer /${PREFIX} /sensor11 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-custom-app-producer /${PREFIX} /sensor12 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-custom-app-producer /${PREFIX} /sensor13 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-custom-app-producer /${PREFIX} /sensor14 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-custom-app-producer /${PREFIX} /sensor15 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-custom-app-producer /${PREFIX} /sensor16 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-custom-app-producer /${PREFIX} /sensor17 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-custom-app-producer /${PREFIX} /sensor18 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-custom-app-producer /${PREFIX} /sensor19 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-custom-app-producer /${PREFIX} /sensor20 &
	fi
	if [ ${device} == rtr2 ]; then
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceA-app /${PREFIX} /serviceP1 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceA-app /${PREFIX} /serviceP2 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceA-app /${PREFIX} /serviceP3 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceA-app /${PREFIX} /serviceP4 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceA-app /${PREFIX} /serviceP5 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceA-app /${PREFIX} /serviceP6 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceA-app /${PREFIX} /serviceP7 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceA-app /${PREFIX} /serviceP8 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceA-app /${PREFIX} /serviceP9 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceA-app /${PREFIX} /serviceP10 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceA-app /${PREFIX} /serviceP11 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceA-app /${PREFIX} /serviceP12 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceA-app /${PREFIX} /serviceP13 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceA-app /${PREFIX} /serviceP14 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceA-app /${PREFIX} /serviceP15 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceA-app /${PREFIX} /serviceP16 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceA-app /${PREFIX} /serviceP17 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceA-app /${PREFIX} /serviceP18 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceA-app /${PREFIX} /serviceP19 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceA-app /${PREFIX} /serviceP20 &
	fi
	if [ ${device} == rtr3 ]; then
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceA-app /${PREFIX} /serviceP21 &
	fi
	if [ ${device} == consumer ]; then
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-orchestratorA-app /${PREFIX} /serviceOrchestration &
		sleep 1
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-custom-app-consumer /${PREFIX} ~/mini-ndn/workflows/20-sensor.json 1
	fi
fi

if [ ${scenario} == run_20Sensor_OrchB ]; then
	if [ ${device} == rtr1 ]; then
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-custom-app-producer /${PREFIX} /sensor1 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-custom-app-producer /${PREFIX} /sensor2 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-custom-app-producer /${PREFIX} /sensor3 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-custom-app-producer /${PREFIX} /sensor4 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-custom-app-producer /${PREFIX} /sensor5 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-custom-app-producer /${PREFIX} /sensor6 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-custom-app-producer /${PREFIX} /sensor7 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-custom-app-producer /${PREFIX} /sensor8 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-custom-app-producer /${PREFIX} /sensor9 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-custom-app-producer /${PREFIX} /sensor10 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-custom-app-producer /${PREFIX} /sensor11 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-custom-app-producer /${PREFIX} /sensor12 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-custom-app-producer /${PREFIX} /sensor13 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-custom-app-producer /${PREFIX} /sensor14 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-custom-app-producer /${PREFIX} /sensor15 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-custom-app-producer /${PREFIX} /sensor16 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-custom-app-producer /${PREFIX} /sensor17 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-custom-app-producer /${PREFIX} /sensor18 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-custom-app-producer /${PREFIX} /sensor19 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-custom-app-producer /${PREFIX} /sensor20 &
	fi
	if [ ${device} == rtr2 ]; then
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceB-app /${PREFIX} /serviceP1 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceB-app /${PREFIX} /serviceP2 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceB-app /${PREFIX} /serviceP3 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceB-app /${PREFIX} /serviceP4 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceB-app /${PREFIX} /serviceP5 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceB-app /${PREFIX} /serviceP6 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceB-app /${PREFIX} /serviceP7 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceB-app /${PREFIX} /serviceP8 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceB-app /${PREFIX} /serviceP9 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceB-app /${PREFIX} /serviceP10 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceB-app /${PREFIX} /serviceP11 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceB-app /${PREFIX} /serviceP12 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceB-app /${PREFIX} /serviceP13 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceB-app /${PREFIX} /serviceP14 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceB-app /${PREFIX} /serviceP15 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceB-app /${PREFIX} /serviceP16 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceB-app /${PREFIX} /serviceP17 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceB-app /${PREFIX} /serviceP18 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceB-app /${PREFIX} /serviceP19 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceB-app /${PREFIX} /serviceP20 &
	fi
	if [ ${device} == rtr3 ]; then
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceB-app /${PREFIX} /serviceP21 &
	fi
	if [ ${device} == consumer ]; then
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-orchestratorB-app /${PREFIX} /serviceOrchestration &
		sleep 1
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-custom-app-consumer /${PREFIX} ~/mini-ndn/workflows/20-sensor.json 2
	fi
fi

if [ ${scenario} == run_20Sensor_nesco ]; then
	if [ ${device} == rtr1 ]; then
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-custom-app-producer /${PREFIX} /sensor1 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-custom-app-producer /${PREFIX} /sensor2 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-custom-app-producer /${PREFIX} /sensor3 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-custom-app-producer /${PREFIX} /sensor4 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-custom-app-producer /${PREFIX} /sensor5 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-custom-app-producer /${PREFIX} /sensor6 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-custom-app-producer /${PREFIX} /sensor7 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-custom-app-producer /${PREFIX} /sensor8 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-custom-app-producer /${PREFIX} /sensor9 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-custom-app-producer /${PREFIX} /sensor10 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-custom-app-producer /${PREFIX} /sensor11 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-custom-app-producer /${PREFIX} /sensor12 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-custom-app-producer /${PREFIX} /sensor13 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-custom-app-producer /${PREFIX} /sensor14 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-custom-app-producer /${PREFIX} /sensor15 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-custom-app-producer /${PREFIX} /sensor16 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-custom-app-producer /${PREFIX} /sensor17 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-custom-app-producer /${PREFIX} /sensor18 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-custom-app-producer /${PREFIX} /sensor19 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-custom-app-producer /${PREFIX} /sensor20 &
	fi
	if [ ${device} == rtr2 ]; then
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-forwarder-app /${PREFIX} /serviceP1 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-forwarder-app /${PREFIX} /serviceP2 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-forwarder-app /${PREFIX} /serviceP3 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-forwarder-app /${PREFIX} /serviceP4 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-forwarder-app /${PREFIX} /serviceP5 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-forwarder-app /${PREFIX} /serviceP6 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-forwarder-app /${PREFIX} /serviceP7 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-forwarder-app /${PREFIX} /serviceP8 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-forwarder-app /${PREFIX} /serviceP9 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-forwarder-app /${PREFIX} /serviceP10 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-forwarder-app /${PREFIX} /serviceP11 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-forwarder-app /${PREFIX} /serviceP12 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-forwarder-app /${PREFIX} /serviceP13 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-forwarder-app /${PREFIX} /serviceP14 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-forwarder-app /${PREFIX} /serviceP15 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-forwarder-app /${PREFIX} /serviceP16 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-forwarder-app /${PREFIX} /serviceP17 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-forwarder-app /${PREFIX} /serviceP18 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-forwarder-app /${PREFIX} /serviceP19 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-forwarder-app /${PREFIX} /serviceP20 &
	fi
	if [ ${device} == rtr3 ]; then
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-forwarder-app /${PREFIX} /serviceP21 &
	fi
	if [ ${device} == consumer ]; then
		sleep 1
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-custom-app-consumer /${PREFIX} ~/mini-ndn/workflows/20-sensor.json 0
	fi
fi

if [ ${scenario} == run_20Linear_OrchA ]; then
	if [ ${device} == producer ]; then
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-custom-app-producer /${PREFIX} /sensor &
	fi
	if [ ${device} == rtr1 ]; then
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceA-app /${PREFIX} /serviceL2 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceA-app /${PREFIX} /serviceL6 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceA-app /${PREFIX} /serviceL10 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceA-app /${PREFIX} /serviceL14 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceA-app /${PREFIX} /serviceL18 &
	fi
	if [ ${device} == rtr2 ]; then
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceA-app /${PREFIX} /serviceL1 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceA-app /${PREFIX} /serviceL3 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceA-app /${PREFIX} /serviceL5 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceA-app /${PREFIX} /serviceL7 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceA-app /${PREFIX} /serviceL9 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceA-app /${PREFIX} /serviceL11 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceA-app /${PREFIX} /serviceL13 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceA-app /${PREFIX} /serviceL15 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceA-app /${PREFIX} /serviceL17 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceA-app /${PREFIX} /serviceL19 &
	fi
	if [ ${device} == rtr3 ]; then
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceA-app /${PREFIX} /serviceL4 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceA-app /${PREFIX} /serviceL8 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceA-app /${PREFIX} /serviceL12 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceA-app /${PREFIX} /serviceL16 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceA-app /${PREFIX} /serviceL20 &
	fi
	if [ ${device} == consumer ]; then
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-orchestratorA-app /${PREFIX} /serviceOrchestration &
		sleep 1
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-custom-app-consumer /${PREFIX} ~/mini-ndn/workflows/20-linear.json 1
	fi
fi

if [ ${scenario} == run_20Linear_OrchB ]; then
	if [ ${device} == producer ]; then
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-custom-app-producer /${PREFIX} /sensor &
	fi
	if [ ${device} == rtr1 ]; then
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceB-app /${PREFIX} /serviceL2 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceB-app /${PREFIX} /serviceL6 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceB-app /${PREFIX} /serviceL10 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceB-app /${PREFIX} /serviceL14 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceB-app /${PREFIX} /serviceL18 &
	fi
	if [ ${device} == rtr2 ]; then
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceB-app /${PREFIX} /serviceL1 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceB-app /${PREFIX} /serviceL3 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceB-app /${PREFIX} /serviceL5 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceB-app /${PREFIX} /serviceL7 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceB-app /${PREFIX} /serviceL9 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceB-app /${PREFIX} /serviceL11 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceB-app /${PREFIX} /serviceL13 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceB-app /${PREFIX} /serviceL15 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceB-app /${PREFIX} /serviceL17 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceB-app /${PREFIX} /serviceL19 &
	fi
	if [ ${device} == rtr3 ]; then
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceB-app /${PREFIX} /serviceL4 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceB-app /${PREFIX} /serviceL8 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceB-app /${PREFIX} /serviceL12 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceB-app /${PREFIX} /serviceL16 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceB-app /${PREFIX} /serviceL20 &
	fi
	if [ ${device} == consumer ]; then
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-orchestratorB-app /${PREFIX} /serviceOrchestration &
		sleep 1
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-custom-app-consumer /${PREFIX} ~/mini-ndn/workflows/20-linear.json 2
	fi
fi

if [ ${scenario} == run_20Linear_nesco ]; then
	if [ ${device} == producer ]; then
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-custom-app-producer /${PREFIX} /sensor &
	fi
	if [ ${device} == rtr1 ]; then
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-forwarder-app /${PREFIX} /serviceL2 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-forwarder-app /${PREFIX} /serviceL6 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-forwarder-app /${PREFIX} /serviceL10 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-forwarder-app /${PREFIX} /serviceL14 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-forwarder-app /${PREFIX} /serviceL18 &
	fi
	if [ ${device} == rtr2 ]; then
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-forwarder-app /${PREFIX} /serviceL1 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-forwarder-app /${PREFIX} /serviceL3 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-forwarder-app /${PREFIX} /serviceL5 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-forwarder-app /${PREFIX} /serviceL7 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-forwarder-app /${PREFIX} /serviceL9 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-forwarder-app /${PREFIX} /serviceL11 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-forwarder-app /${PREFIX} /serviceL13 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-forwarder-app /${PREFIX} /serviceL15 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-forwarder-app /${PREFIX} /serviceL17 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-forwarder-app /${PREFIX} /serviceL19 &
	fi
	if [ ${device} == rtr3 ]; then
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-forwarder-app /${PREFIX} /serviceL4 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-forwarder-app /${PREFIX} /serviceL8 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-forwarder-app /${PREFIX} /serviceL12 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-forwarder-app /${PREFIX} /serviceL16 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-forwarder-app /${PREFIX} /serviceL20 &
	fi
	if [ ${device} == consumer ]; then
		sleep 1
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-custom-app-consumer /${PREFIX} ~/mini-ndn/workflows/20-linear.json 0
	fi
fi












# stop NFD to clear cache and forwarding table entries
#ndf-stop



