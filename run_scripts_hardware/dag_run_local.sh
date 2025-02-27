#! /bin/bash



username=cabeee

lenovoWiFiIP=192.168.20.143
lenovoETHIP=192.168.20.144
jetsonETHIP=192.168.20.145
rpi4consumerETHIP=192.168.20.146
rpi4consumerWiFiIP=192.168.20.147
rpi5consumerETHIP=192.168.20.148
rpi5consumerWiFiIP=192.168.20.149
rpi3rtr1ETHIP=192.168.20.150
rpi3rtr1WiFiIP=192.168.20.151
rpi3rtr2ETHIP=192.168.20.152
rpi3rtr2WiFiIP=192.168.20.153
rpi3rtr3ETHIP=192.168.20.154
rpi3rtr3WiFiIP=192.168.20.155
rpi3producerETHIP=192.168.20.156
rpi3producerWiFiIP=192.168.20.157
rpi5rtr1ETHIP=192.168.20.158
rpi5rtr1WiFiIP=192.168.20.159
rpi5rtr2ETHIP=192.168.20.160
rpi5rtr2WiFiIP=192.168.20.161
rpi5rtr3ETHIP=192.168.20.162
rpi5rtr3WiFiIP=192.168.20.163
rpi5producerETHIP=192.168.20.164
rpi5producerWiFiIP=192.168.20.165

lenovoETHMAC=d8:cb:8a:bc:a3:94
jetsonETHMAC=00:00:00:00:00:01
jetsonUSBETHMAC=00:10:60:b1:f1:1b
rpi4consumerETHMAC=d8:3a:dd:2e:c5:1f
rpi4consumerWiFiMAC=d8:3a:dd:2e:c5:20
rpi5consumerETHMAC=2c:cf:67:6d:e3:7b
rpi5consumerWiFiMAC=2c:cf:67:6d:e3:7c
rpi3rtr1ETHMAC=b8:27:eb:19:bf:bf
rpi3rtr1WiFiMAC=b8:27:eb:4c:ea:ea
rpi3rtr1USBETHMAC=a0:ce:c8:cf:24:17
rpi3rtr2ETHMAC=b8:27:eb:be:80:60
rpi3rtr2WiFiMAC=b8:27:eb:eb:d5:35
rpi3rtr2USBETHMAC=00:50:b6:58:01:ed
rpi3rtr3ETHMAC=b8:27:eb:13:9e:0a
rpi3rtr3WiFiMAC=b8:27:eb:46:cb:5f
rpi3rtr3USBETHMAC=00:14:d1:b0:24:ed
rpi3producerETHMAC=b8:27:eb:a6:27:12
rpi3producerWiFiMAC=b8:27:eb:f3:72:47
rpi5rtr1ETHMAC=2c:cf:67:4d:ad:2b
rpi5rtr1WiFiMAC=2c:cf:67:4d:ad:2c
rpi5rtr2ETHMAC=2c:cf:67:4d:af:4a
rpi5rtr2WiFiMAC=2c:cf:67:4d:af:4b
rpi5rtr3ETHMAC=2c:cf:67:4d:af:02
rpi5rtr3WiFiMAC=2c:cf:67:4d:af:03
rpi5producerETHMAC=2c:cf:67:6d:e3:69
rpi5producerWiFiMAC=2c:cf:67:6d:e3:6c

lenovoETHinterface=eno1
jetsonETHinterface=eth0
jetsonUSBETHinterface=eth1
rpi4consumerETHinterface=eth0
rpi4consumerWiFiinterface=wlan0
rpi5consumerETHinterface=eth0
rpi5consumerWiFiinterface=wlan0
rpi3rtr1ETHinterface=eth0
rpi3rtr1WiFiinterface=wlan0
rpi3rtr1USBETHinterface=enxa0cec8cf2417
rpi3rtr2ETHinterface=eth0
rpi3rtr2WiFiinterface=wlan0
rpi3rtr2USBETHinterface=enx0050b65801ed
rpi3rtr3ETHinterface=eth0
rpi3rtr3WiFiinterface=wlan0
rpi3rtr3USBETHinterface=enx0014d1b024ed
rpi3producerETHinterface=eth0
rpi3producerWiFiinterface=wlan0
rpi5rtr1ETHinterface=eth0
rpi5rtr1WiFiinterface=wlan0
rpi5rtr2ETHinterface=eth0
rpi5rtr2WiFiinterface=wlan0
rpi5rtr3ETHinterface=eth0
rpi5rtr3WiFiinterface=wlan0
rpi5producerETHinterface=eth0
rpi5producerWiFiinterface=wlan0



consumerIP=${rpi5consumerETHIP}
rtr1IP=${rpi5rtr1ETHIP}
rtr2IP=${rpi5rtr2ETHIP}
rtr3IP=${rpi5rtr3ETHIP}
producerIP=${rpi5producerETHIP}

consumerMAC=${rpi5consumerETHMAC}
rtr1MAC=${rpi5rtr1ETHMAC}
rtr2MAC=${rpi5rtr2ETHMAC}
rtr3MAC=${rpi5rtr3ETHMAC}
producerMAC=${rpi5producerETHMAC}

consumerinterface=${rpi5consumerETHinterface}
rtr1interface=${rpi5rtr1ETHinterface}
rtr2interface=${rpi5rtr2ETHinterface}
rtr3interface=${rpi5rtr3ETHinterface}
producerinterface=${rpi5producerETHinterface}



device=$1
scenario=$2
sleepVal=$3
changeLinkDelay=$4
linkDelayMS=$5
consumerLog=$6


NDN_DIR="$HOME/ndn"
RUN_DIR="$NDN_DIR/ndn-cxx/run_scripts_hardware"
WORKFLOW_DIR="$NDN_DIR/ndn-cxx/run_scripts_hardware/workflows"

# stop NFD to clear cache and forwarding table entries
#nfd-stop &
nfd-stop >/dev/null 2>&1 &

sleep 5

# start NFD
#nfd-start &
nfd-start >/dev/null 2>&1 &

sleep 5



# change link delay
if [ ${changeLinkDelay} == 1 ]; then
	sudo tc qdisc del dev eth0 root # remove any existing delay
#	if [ ${device} == producer ]; then
#		echo -en "Changing link delay for the producer\r\n"
#		ping_results=$(ping -c 10 "${rtr1IP}" | grep 'time=' | awk -F'time=' '{print $2}' | awk '{print $1}')
#	fi
#	if [ ${device} == rtr1 ]; then
#		echo -en "Changing link delay for rtr1\r\n"
#		ping_results=$(ping -c 10 "${rtr2IP}" | grep 'time=' | awk -F'time=' '{print $2}' | awk '{print $1}')
#	fi
#	if [ ${device} == rtr2 ]; then
#		echo -en "Changing link delay for rtr2\r\n"
#		ping_results=$(ping -c 10 "${rtr3IP}" | grep 'time=' | awk -F'time=' '{print $2}' | awk '{print $1}')
#	fi
#	if [ ${device} == rtr3 ]; then
#		echo -en "Changing link delay for rtr3\r\n"
#		ping_results=$(ping -c 10 "${consumerIP}" | grep 'time=' | awk -F'time=' '{print $2}' | awk '{print $1}')
#	fi
#	if [ ${device} == consumer ]; then
#		echo -en "Changing link delay for the consumer\r\n"
#		ping_results=$(ping -c 10 "${rtr3IP}" | grep 'time=' | awk -F'time=' '{print $2}' | awk '{print $1}')
#	fi
	# Calculate the average ping time
#	sum=0
#	count=0
#	for time in $ping_results; do
# 		sum=$(echo "$sum + $time" | bc)
#		((count++))
#	done
#	average=$(echo "scale=2; $sum / $count" | bc)
#	echo -en "Average ping time: $average ms\r\n"
#	echo -en "Target link delay: $linkDelayMS ms\r\n"
#	RTTdelayToAdd=$(bc -l <<< "scale=2;$linkDelayMS - ($average/2)")
	RTTdelayToAdd=$linkDelayMS
	echo -en "Adding $RTTdelayToAdd ms of RTT link delay to achieve a final link delay of $linkDelayMS, ping RTT will be twice link delay.\r\n"
	sudo tc qdisc add dev eth0 root netem delay ${RTTdelayToAdd}ms
fi


# create the faces
if [ ${device} == producer ]; then
	echo -en "Creating faces for the producer\r\n"
	sleep ${sleepVal}; nfdc face create remote ether://[${rtr1MAC}] local dev://${producerinterface} persistency permanent
fi
if [ ${device} == rtr1 ]; then
	echo -en "Creating faces for rtr1\r\n"
	sleep ${sleepVal}; nfdc face create remote ether://[${producerMAC}] local dev://${rtr1interface} persistency permanent
	sleep ${sleepVal}; nfdc face create remote ether://[${rtr2MAC}] local dev://${rtr1interface} persistency permanent
fi
if [ ${device} == rtr2 ]; then
	echo -en "Creating faces for rtr2\r\n"
	sleep ${sleepVal}; nfdc face create remote ether://[${rtr1MAC}] local dev://${rtr2interface} persistency permanent
	sleep ${sleepVal}; nfdc face create remote ether://[${rtr3MAC}] local dev://${rtr2interface} persistency permanent
fi
if [ ${device} == rtr3 ]; then
	echo -en "Creating faces for rtr3\r\n"
	sleep ${sleepVal}; nfdc face create remote ether://[${rtr2MAC}] local dev://${rtr3interface} persistency permanent
	sleep ${sleepVal}; nfdc face create remote ether://[${consumerMAC}] local dev://${rtr3interface} persistency permanent
fi
if [ ${device} == consumer ]; then
	echo -en "Creating faces for the consumer\r\n"
	sleep ${sleepVal}; nfdc face create remote ether://[${rtr3MAC}] local dev://${consumerinterface} persistency permanent
fi


if 	[ ${scenario} == run_4DAG_OrchA ] || \
	[ ${scenario} == run_8DAG_OrchA ] || \
	[ ${scenario} == run_8DAG_Caching_OrchA ] || \
	[ ${scenario} == run_20Parallel_OrchA ] || \
	[ ${scenario} == run_20Sensor_OrchA ] || \
	[ ${scenario} == run_20Linear_OrchA ] || \
	[ ${scenario} == run_20Reuse_OrchA ] || \
	[ ${scenario} == run_20Scramble_OrchA ]; then
		PREFIX=OrchA
fi
if 	[ ${scenario} == run_4DAG_OrchB ] || \
	[ ${scenario} == run_8DAG_OrchB ] || \
	[ ${scenario} == run_8DAG_Caching_OrchB ] || \
	[ ${scenario} == run_20Parallel_OrchB ] || \
	[ ${scenario} == run_20Sensor_OrchB ] || \
	[ ${scenario} == run_20Linear_OrchB ] || \
	[ ${scenario} == run_20Reuse_OrchB ] || \
	[ ${scenario} == run_20Scramble_OrchB ]; then
		PREFIX=OrchB
fi
if 	[ ${scenario} == run_4DAG_nesco ] || \
	[ ${scenario} == run_8DAG_nesco ] || \
	[ ${scenario} == run_8DAG_Caching_nesco ] || \
	[ ${scenario} == run_20Parallel_nesco ] || \
	[ ${scenario} == run_20Sensor_nesco ] || \
	[ ${scenario} == run_20Linear_nesco ] || \
	[ ${scenario} == run_20Reuse_nesco ] || \
	[ ${scenario} == run_20Scramble_nesco ]; then
		PREFIX=nesco
fi
if 	[ ${scenario} == run_4DAG_nescoSCOPT ] || \
	[ ${scenario} == run_8DAG_nescoSCOPT ] || \
	[ ${scenario} == run_8DAG_Caching_nescoSCOPT ] || \
	[ ${scenario} == run_20Parallel_nescoSCOPT ] || \
	[ ${scenario} == run_20Sensor_nescoSCOPT ] || \
	[ ${scenario} == run_20Linear_nescoSCOPT ] || \
	[ ${scenario} == run_20Reuse_nescoSCOPT ] || \
	[ ${scenario} == run_20Scramble_nescoSCOPT ]; then
		PREFIX=nescoSCOPT
fi


# add routes for all the PREFIXes to all nodes
if 	[ ${scenario} == run_4DAG_OrchA ] || \
	[ ${scenario} == run_4DAG_OrchB ] || \
	[ ${scenario} == run_4DAG_nesco ] || \
	[ ${scenario} == run_4DAG_nescoSCOPT ] || \
	[ ${scenario} == run_8DAG_OrchA ] || \
	[ ${scenario} == run_8DAG_OrchB ] || \
	[ ${scenario} == run_8DAG_nesco ] || \
	[ ${scenario} == run_8DAG_nescoSCOPT ] || \
	[ ${scenario} == run_8DAG_Caching_OrchA ] || \
	[ ${scenario} == run_8DAG_Caching_OrchB ] || \
	[ ${scenario} == run_8DAG_Caching_nesco ] || \
	[ ${scenario} == run_8DAG_Caching_nescoSCOPT ]; then
	echo -en "4DAG or 8DAG scenario\r\n"
	if [ ${device} == consumer ]; then
		echo -en "Setting up routes for the consumer\r\n"
		sleep ${sleepVal}; nfdc route add /${PREFIX} ether://[${rtr3MAC}]
		#sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceOrchestration ether://[${consumerMAC}]
	fi
	
	if [ ${device} == rtr3 ]; then
		echo -en "Setting up routes for rtr3\r\n"
		sleep ${sleepVal}; nfdc route add /${PREFIX} ether://[${rtr3MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/sensor ether://[${rtr2MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/service2 ether://[${rtr2MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/service3 ether://[${rtr2MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/service4 ether://[${rtr2MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/service6 ether://[${rtr2MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/service7 ether://[${rtr2MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/service8 ether://[${rtr2MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceOrchestration ether://[${consumerMAC}]
	fi

	if [ ${device} == rtr2 ]; then
		echo -en "Setting up routes for rtr2\r\n"
		sleep ${sleepVal}; nfdc route add /${PREFIX} ether://[${rtr2MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/sensor ether://[${rtr1MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/service2 ether://[${rtr1MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/service1 ether://[${rtr3MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/service6 ether://[${rtr1MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/service5 ether://[${rtr3MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceOrchestration ether://[${rtr3MAC}]
	fi

	if [ ${device} == rtr1 ]; then
		echo -en "Setting up routes for rtr1\r\n"
		sleep ${sleepVal}; nfdc route add /${PREFIX} ether://[${rtr1MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/sensor ether://[${producerMAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/service1 ether://[${rtr2MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/service3 ether://[${rtr2MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/service4 ether://[${rtr2MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/service5 ether://[${rtr2MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/service7 ether://[${rtr2MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/service8 ether://[${rtr2MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceOrchestration ether://[${rtr2MAC}]
	fi

	if [ ${device} == producer ]; then
		echo -en "Setting up routes for rtr3\r\n"
		sleep ${sleepVal}; nfdc route add /${PREFIX} ether://[${producerMAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/service1 ether://[${rtr1MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/service2 ether://[${rtr1MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/service3 ether://[${rtr1MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/service4 ether://[${rtr1MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/service5 ether://[${rtr1MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/service6 ether://[${rtr1MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/service7 ether://[${rtr1MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/service8 ether://[${rtr1MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceOrchestration ether://[${rtr1MAC}]
	fi
fi

if 	[ ${scenario} == run_20Parallel_OrchA ] || \
	[ ${scenario} == run_20Parallel_OrchB ] || \
	[ ${scenario} == run_20Parallel_nesco ] || \
	[ ${scenario} == run_20Parallel_nescoSCOPT ]; then
	echo -en "20Parallel scenario\r\n"
	if [ ${device} == consumer ]; then
		echo -en "Setting up routes for the consumer\r\n"
		sleep ${sleepVal}; nfdc route add /${PREFIX} ether://[${rtr3MAC}]
		#sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceOrchestration ether://[${consumerMAC}]
	fi
	if [ ${device} == rtr3 ]; then
		echo -en "Setting up routes for rtr3\r\n"
		sleep ${sleepVal}; nfdc route add /${PREFIX} ether://[${rtr3MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/sensor ether://[${rtr2MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceP1 ether://[${rtr2MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceP2 ether://[${rtr2MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceP3 ether://[${rtr2MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceP4 ether://[${rtr2MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceP5 ether://[${rtr2MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceP6 ether://[${rtr2MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceP7 ether://[${rtr2MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceP8 ether://[${rtr2MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceP9 ether://[${rtr2MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceP10 ether://[${rtr2MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceP11 ether://[${rtr2MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceP12 ether://[${rtr2MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceP13 ether://[${rtr2MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceP14 ether://[${rtr2MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceP15 ether://[${rtr2MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceP16 ether://[${rtr2MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceP17 ether://[${rtr2MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceP18 ether://[${rtr2MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceP19 ether://[${rtr2MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceP20 ether://[${rtr2MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceOrchestration ether://[${consumerMAC}]
	fi
	if [ ${device} == rtr2 ]; then
		echo -en "Setting up routes for rtr2\r\n"
		sleep ${sleepVal}; nfdc route add /${PREFIX} ether://[${rtr2MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/sensor ether://[${rtr1MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceP21 ether://[${rtr3MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceOrchestration ether://[${rtr3MAC}]
	fi
	if [ ${device} == rtr1 ]; then
		echo -en "Setting up routes for rtr1\r\n"
		sleep ${sleepVal}; nfdc route add /${PREFIX}/sensor ether://[${producerMAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceP1 ether://[${rtr2MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceP2 ether://[${rtr2MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceP3 ether://[${rtr2MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceP4 ether://[${rtr2MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceP5 ether://[${rtr2MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceP6 ether://[${rtr2MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceP7 ether://[${rtr2MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceP8 ether://[${rtr2MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceP9 ether://[${rtr2MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceP10 ether://[${rtr2MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceP11 ether://[${rtr2MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceP12 ether://[${rtr2MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceP13 ether://[${rtr2MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceP14 ether://[${rtr2MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceP15 ether://[${rtr2MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceP16 ether://[${rtr2MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceP17 ether://[${rtr2MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceP18 ether://[${rtr2MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceP19 ether://[${rtr2MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceP20 ether://[${rtr2MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceP21 ether://[${rtr2MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceOrchestration ether://[${rtr2MAC}]
	fi
	if [ ${device} == producer ]; then
		echo -en "Setting up routes for producer\r\n"
		sleep ${sleepVal}; nfdc route add /${PREFIX} ether://[${producerMAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceP1 ether://[${rtr1MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceP2 ether://[${rtr1MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceP3 ether://[${rtr1MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceP4 ether://[${rtr1MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceP5 ether://[${rtr1MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceP6 ether://[${rtr1MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceP7 ether://[${rtr1MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceP8 ether://[${rtr1MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceP9 ether://[${rtr1MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceP10 ether://[${rtr1MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceP11 ether://[${rtr1MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceP12 ether://[${rtr1MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceP13 ether://[${rtr1MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceP14 ether://[${rtr1MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceP15 ether://[${rtr1MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceP16 ether://[${rtr1MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceP17 ether://[${rtr1MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceP18 ether://[${rtr1MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceP19 ether://[${rtr1MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceP20 ether://[${rtr1MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceP21 ether://[${rtr1MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceOrchestration ether://[${rtr1MAC}]
	fi
	


fi

if 	[ ${scenario} == run_20Sensor_OrchA ] || \
	[ ${scenario} == run_20Sensor_OrchB ] || \
	[ ${scenario} == run_20Sensor_nesco ] || \
	[ ${scenario} == run_20Sensor_nescoSCOPT ]; then
	if [ ${device} == consumer ]; then
		sleep ${sleepVal}; nfdc route add /${PREFIX} ether://[${rtr3MAC}]
		#sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceOrchestration ether://[${consumerMAC}]
	fi
	if [ ${device} == rtr3 ]; then
		sleep ${sleepVal}; nfdc route add /${PREFIX} ether://[${rtr3MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/sensor1 ether://[${rtr2MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/sensor2 ether://[${rtr2MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/sensor3 ether://[${rtr2MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/sensor4 ether://[${rtr2MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/sensor5 ether://[${rtr2MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/sensor6 ether://[${rtr2MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/sensor7 ether://[${rtr2MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/sensor8 ether://[${rtr2MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/sensor9 ether://[${rtr2MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/sensor10 ether://[${rtr2MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/sensor11 ether://[${rtr2MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/sensor12 ether://[${rtr2MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/sensor13 ether://[${rtr2MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/sensor14 ether://[${rtr2MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/sensor15 ether://[${rtr2MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/sensor16 ether://[${rtr2MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/sensor17 ether://[${rtr2MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/sensor18 ether://[${rtr2MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/sensor19 ether://[${rtr2MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/sensor20 ether://[${rtr2MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceP1 ether://[${rtr2MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceP2 ether://[${rtr2MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceP3 ether://[${rtr2MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceP4 ether://[${rtr2MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceP5 ether://[${rtr2MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceP6 ether://[${rtr2MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceP7 ether://[${rtr2MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceP8 ether://[${rtr2MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceP9 ether://[${rtr2MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceP10 ether://[${rtr2MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceP11 ether://[${rtr2MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceP12 ether://[${rtr2MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceP13 ether://[${rtr2MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceP14 ether://[${rtr2MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceP15 ether://[${rtr2MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceP16 ether://[${rtr2MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceP17 ether://[${rtr2MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceP18 ether://[${rtr2MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceP19 ether://[${rtr2MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceP20 ether://[${rtr2MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceOrchestration ether://[${consumerMAC}]
	fi
	if [ ${device} == rtr2 ]; then
		sleep ${sleepVal}; nfdc route add /${PREFIX} ether://[${rtr2MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/sensor1 ether://[${rtr1MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/sensor2 ether://[${rtr1MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/sensor3 ether://[${rtr1MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/sensor4 ether://[${rtr1MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/sensor5 ether://[${rtr1MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/sensor6 ether://[${rtr1MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/sensor7 ether://[${rtr1MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/sensor8 ether://[${rtr1MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/sensor9 ether://[${rtr1MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/sensor10 ether://[${rtr1MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/sensor11 ether://[${rtr1MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/sensor12 ether://[${rtr1MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/sensor13 ether://[${rtr1MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/sensor14 ether://[${rtr1MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/sensor15 ether://[${rtr1MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/sensor16 ether://[${rtr1MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/sensor17 ether://[${rtr1MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/sensor18 ether://[${rtr1MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/sensor19 ether://[${rtr1MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/sensor20 ether://[${rtr1MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceP21 ether://[${rtr3MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceOrchestration ether://[${rtr3MAC}]
	fi
	if [ ${device} == rtr1 ]; then
		sleep ${sleepVal}; nfdc route add /${PREFIX} ether://[${rtr1MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/sensor1 ether://[${producerMAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/sensor2 ether://[${producerMAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/sensor3 ether://[${producerMAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/sensor4 ether://[${producerMAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/sensor5 ether://[${producerMAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/sensor6 ether://[${producerMAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/sensor7 ether://[${producerMAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/sensor8 ether://[${producerMAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/sensor9 ether://[${producerMAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/sensor10 ether://[${producerMAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/sensor11 ether://[${producerMAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/sensor12 ether://[${producerMAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/sensor13 ether://[${producerMAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/sensor14 ether://[${producerMAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/sensor15 ether://[${producerMAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/sensor16 ether://[${producerMAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/sensor17 ether://[${producerMAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/sensor18 ether://[${producerMAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/sensor19 ether://[${producerMAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/sensor20 ether://[${producerMAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceP1 ether://[${rtr2MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceP2 ether://[${rtr2MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceP3 ether://[${rtr2MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceP4 ether://[${rtr2MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceP5 ether://[${rtr2MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceP6 ether://[${rtr2MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceP7 ether://[${rtr2MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceP8 ether://[${rtr2MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceP9 ether://[${rtr2MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceP10 ether://[${rtr2MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceP11 ether://[${rtr2MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceP12 ether://[${rtr2MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceP13 ether://[${rtr2MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceP14 ether://[${rtr2MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceP15 ether://[${rtr2MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceP16 ether://[${rtr2MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceP17 ether://[${rtr2MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceP18 ether://[${rtr2MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceP19 ether://[${rtr2MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceP20 ether://[${rtr2MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceP21 ether://[${rtr2MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceOrchestration ether://[${rtr2MAC}]
	fi
	if [ ${device} == producer ]; then
		echo -en "Setting up routes for producer\r\n"
		sleep ${sleepVal}; nfdc route add /${PREFIX} ether://[${producerMAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceP1 ether://[${rtr1MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceP2 ether://[${rtr1MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceP3 ether://[${rtr1MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceP4 ether://[${rtr1MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceP5 ether://[${rtr1MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceP6 ether://[${rtr1MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceP7 ether://[${rtr1MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceP8 ether://[${rtr1MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceP9 ether://[${rtr1MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceP10 ether://[${rtr1MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceP11 ether://[${rtr1MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceP12 ether://[${rtr1MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceP13 ether://[${rtr1MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceP14 ether://[${rtr1MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceP15 ether://[${rtr1MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceP16 ether://[${rtr1MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceP17 ether://[${rtr1MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceP18 ether://[${rtr1MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceP19 ether://[${rtr1MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceP20 ether://[${rtr1MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceP21 ether://[${rtr1MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceOrchestration ether://[${rtr1MAC}]
	fi
		


fi

if 	[ ${scenario} == run_20Linear_OrchA ] || \
	[ ${scenario} == run_20Linear_OrchB ] || \
	[ ${scenario} == run_20Linear_nesco ] || \
	[ ${scenario} == run_20Linear_nescoSCOPT ]; then
	if [ ${device} == consumer ]; then
		sleep ${sleepVal}; nfdc route add /${PREFIX} ether://[${rtr3MAC}]
		#sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceOrchestration ether://[${consumerMAC}]
	fi
	if [ ${device} == rtr3 ]; then
		sleep ${sleepVal}; nfdc route add /${PREFIX} ether://[${rtr3MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/sensorL ether://[${rtr2MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceL1 ether://[${rtr2MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceL3 ether://[${rtr2MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceL5 ether://[${rtr2MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceL7 ether://[${rtr2MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceL9 ether://[${rtr2MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceL11 ether://[${rtr2MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceL13 ether://[${rtr2MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceL15 ether://[${rtr2MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceL17 ether://[${rtr2MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceL19 ether://[${rtr2MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceL2 ether://[${rtr2MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceL6 ether://[${rtr2MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceL10 ether://[${rtr2MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceL14 ether://[${rtr2MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceL18 ether://[${rtr2MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceOrchestration ether://[${consumerMAC}]
	fi
	if [ ${device} == rtr2 ]; then
		sleep ${sleepVal}; nfdc route add /${PREFIX} ether://[${rtr2MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/sensorL ether://[${rtr1MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceL4 ether://[${rtr3MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceL8 ether://[${rtr3MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceL12 ether://[${rtr3MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceL16 ether://[${rtr3MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceL20 ether://[${rtr3MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceL2 ether://[${rtr1MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceL6 ether://[${rtr1MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceL10 ether://[${rtr1MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceL14 ether://[${rtr1MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceL18 ether://[${rtr1MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceOrchestration ether://[${rtr3MAC}]

	fi
	if [ ${device} == rtr1 ]; then
		sleep ${sleepVal}; nfdc route add /${PREFIX} ether://[${rtr1MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/sensorL ether://[${producerMAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceL1 ether://[${rtr2MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceL3 ether://[${rtr2MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceL5 ether://[${rtr2MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceL7 ether://[${rtr2MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceL9 ether://[${rtr2MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceL11 ether://[${rtr2MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceL13 ether://[${rtr2MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceL15 ether://[${rtr2MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceL17 ether://[${rtr2MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceL19 ether://[${rtr2MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceL4 ether://[${rtr2MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceL8 ether://[${rtr2MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceL12 ether://[${rtr2MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceL16 ether://[${rtr2MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceL20 ether://[${rtr2MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceOrchestration ether://[${rtr2MAC}]
	fi
	if [ ${device} == producer ]; then
		sleep ${sleepVal}; nfdc route add /${PREFIX} ether://[${producerMAC}]
		#sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceL1 ether://[${rtr1MAC}]
		#sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceL2 ether://[${rtr1MAC}]
		#sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceL3 ether://[${rtr1MAC}]
		#sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceL4 ether://[${rtr1MAC}]
		#sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceL5 ether://[${rtr1MAC}]
		#sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceL6 ether://[${rtr1MAC}]
		#sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceL7 ether://[${rtr1MAC}]
		#sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceL8 ether://[${rtr1MAC}]
		#sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceL9 ether://[${rtr1MAC}]
		#sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceL10 ether://[${rtr1MAC}]
		#sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceL11 ether://[${rtr1MAC}]
		#sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceL12 ether://[${rtr1MAC}]
		#sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceL13 ether://[${rtr1MAC}]
		#sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceL14 ether://[${rtr1MAC}]
		#sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceL15 ether://[${rtr1MAC}]
		#sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceL16 ether://[${rtr1MAC}]
		#sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceL17 ether://[${rtr1MAC}]
		#sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceL18 ether://[${rtr1MAC}]
		#sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceL19 ether://[${rtr1MAC}]
		#sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceL20 ether://[${rtr1MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceOrchestration ether://[${rtr1MAC}]
	fi
fi

if 	[ ${scenario} == run_20Reuse_OrchA ] || \
	[ ${scenario} == run_20Reuse_OrchB ] || \
	[ ${scenario} == run_20Reuse_nesco ] || \
	[ ${scenario} == run_20Reuse_nescoSCOPT ]; then
	if [ ${device} == consumer ]; then
		sleep ${sleepVal}; nfdc route add /${PREFIX} ether://[${rtr3MAC}]
		#sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceOrchestration ether://[${consumerMAC}]
	fi
	if [ ${device} == rtr3 ]; then
		sleep ${sleepVal}; nfdc route add /${PREFIX} ether://[${rtr3MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/sensorL ether://[${rtr2MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceL1 ether://[${rtr2MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceL3 ether://[${rtr2MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceL5 ether://[${rtr2MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceL7 ether://[${rtr2MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceL9 ether://[${rtr2MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceL2 ether://[${rtr2MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceL6 ether://[${rtr2MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceL10 ether://[${rtr2MAC}]

		sleep ${sleepVal}; nfdc route add /${PREFIX}/sensor1 ether://[${rtr2MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/sensor2 ether://[${rtr2MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/sensor3 ether://[${rtr2MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/sensor4 ether://[${rtr2MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/sensor5 ether://[${rtr2MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/sensor6 ether://[${rtr2MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceP1 ether://[${rtr2MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceP2 ether://[${rtr2MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceP3 ether://[${rtr2MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceP4 ether://[${rtr2MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceP5 ether://[${rtr2MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceP6 ether://[${rtr2MAC}]

		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceOrchestration ether://[${consumerMAC}]
	fi
	if [ ${device} == rtr2 ]; then
		sleep ${sleepVal}; nfdc route add /${PREFIX} ether://[${rtr2MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/sensorL ether://[${rtr1MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceL4 ether://[${rtr3MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceL8 ether://[${rtr3MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceL2 ether://[${rtr1MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceL6 ether://[${rtr1MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceL10 ether://[${rtr1MAC}]

		sleep ${sleepVal}; nfdc route add /${PREFIX}/sensor1 ether://[${rtr1MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/sensor2 ether://[${rtr1MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/sensor3 ether://[${rtr1MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/sensor4 ether://[${rtr1MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/sensor5 ether://[${rtr1MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/sensor6 ether://[${rtr1MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceP22 ether://[${rtr3MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceP23 ether://[${rtr3MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceR1 ether://[${rtr3MAC}]

		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceOrchestration ether://[${rtr3MAC}]

	fi
	if [ ${device} == rtr1 ]; then
		sleep ${sleepVal}; nfdc route add /${PREFIX} ether://[${rtr1MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/sensorL ether://[${producerMAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceL1 ether://[${rtr2MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceL3 ether://[${rtr2MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceL5 ether://[${rtr2MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceL7 ether://[${rtr2MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceL9 ether://[${rtr2MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceL4 ether://[${rtr2MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceL8 ether://[${rtr2MAC}]

		sleep ${sleepVal}; nfdc route add /${PREFIX}/sensor1 ether://[${producerMAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/sensor2 ether://[${producerMAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/sensor3 ether://[${producerMAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/sensor4 ether://[${producerMAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/sensor5 ether://[${producerMAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/sensor6 ether://[${producerMAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceP1 ether://[${rtr2MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceP2 ether://[${rtr2MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceP3 ether://[${rtr2MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceP4 ether://[${rtr2MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceP5 ether://[${rtr2MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceP6 ether://[${rtr2MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceP22 ether://[${rtr2MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceP23 ether://[${rtr2MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceR1 ether://[${rtr2MAC}]

		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceOrchestration ether://[${rtr2MAC}]
	fi
	if [ ${device} == producer ]; then
		sleep ${sleepVal}; nfdc route add /${PREFIX} ether://[${producerMAC}]
		#sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceL1 ether://[${rtr1MAC}]
		#sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceL2 ether://[${rtr1MAC}]
		#sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceL3 ether://[${rtr1MAC}]
		#sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceL4 ether://[${rtr1MAC}]
		#sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceL5 ether://[${rtr1MAC}]
		#sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceL6 ether://[${rtr1MAC}]
		#sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceL7 ether://[${rtr1MAC}]
		#sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceL8 ether://[${rtr1MAC}]
		#sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceL9 ether://[${rtr1MAC}]
		#sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceL10 ether://[${rtr1MAC}]

		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceP1 ether://[${rtr1MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceP2 ether://[${rtr1MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceP3 ether://[${rtr1MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceP4 ether://[${rtr1MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceP5 ether://[${rtr1MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceP6 ether://[${rtr1MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceP22 ether://[${rtr1MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceP23 ether://[${rtr1MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceR1 ether://[${rtr1MAC}]

		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceOrchestration ether://[${rtr1MAC}]
	fi
fi

if 	[ ${scenario} == run_20Scramble_OrchA ] || \
	[ ${scenario} == run_20Scramble_OrchB ] || \
	[ ${scenario} == run_20Scramble_nesco ] || \
	[ ${scenario} == run_20Scramble_nescoSCOPT ]; then
	if [ ${device} == consumer ]; then
		sleep ${sleepVal}; nfdc route add /${PREFIX} ether://[${rtr3MAC}]
		#sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceOrchestration ether://[${consumerMAC}]
	fi
	if [ ${device} == rtr3 ]; then
		#sleep ${sleepVal}; nfdc route add /${PREFIX} ether://[${rtr3MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/sensorL ether://[${rtr2MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceL1 ether://[${rtr2MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceL2 ether://[${rtr2MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceL4 ether://[${rtr2MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceL5 ether://[${rtr2MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceL7 ether://[${rtr2MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceL8 ether://[${rtr2MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceL9 ether://[${rtr2MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceL11 ether://[${rtr2MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceL12 ether://[${rtr2MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceL13 ether://[${rtr2MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceL14 ether://[${rtr2MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceL16 ether://[${rtr2MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceL18 ether://[${rtr2MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceL20 ether://[${rtr2MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceOrchestration ether://[${consumerMAC}]
	fi
	if [ ${device} == rtr2 ]; then
		#sleep ${sleepVal}; nfdc route add /${PREFIX} ether://[${rtr2MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/sensorL ether://[${rtr1MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceL1 ether://[${rtr1MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceL3 ether://[${rtr3MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceL4 ether://[${rtr1MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceL6 ether://[${rtr3MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceL8 ether://[${rtr1MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceL10 ether://[${rtr3MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceL12 ether://[${rtr1MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceL14 ether://[${rtr1MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceL15 ether://[${rtr3MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceL16 ether://[${rtr1MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceL17 ether://[${rtr3MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceL18 ether://[${rtr1MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceL19 ether://[${rtr3MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceL20 ether://[${rtr1MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceOrchestration ether://[${rtr3MAC}]

	fi
	if [ ${device} == rtr1 ]; then
		#sleep ${sleepVal}; nfdc route add /${PREFIX} ether://[${rtr1MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/sensorL ether://[${producerMAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceL2 ether://[${rtr2MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceL3 ether://[${rtr2MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceL5 ether://[${rtr2MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceL6 ether://[${rtr2MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceL7 ether://[${rtr2MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceL9 ether://[${rtr2MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceL10 ether://[${rtr2MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceL11 ether://[${rtr2MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceL13 ether://[${rtr2MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceL15 ether://[${rtr2MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceL17 ether://[${rtr2MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceL19 ether://[${rtr2MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceOrchestration ether://[${rtr2MAC}]
	fi
	if [ ${device} == producer ]; then
		#sleep ${sleepVal}; nfdc route add /${PREFIX} ether://[${producerMAC}]
		#sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceL1 ether://[${rtr1MAC}]
		#sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceL2 ether://[${rtr1MAC}]
		#sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceL3 ether://[${rtr1MAC}]
		#sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceL4 ether://[${rtr1MAC}]
		#sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceL5 ether://[${rtr1MAC}]
		#sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceL6 ether://[${rtr1MAC}]
		#sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceL7 ether://[${rtr1MAC}]
		#sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceL8 ether://[${rtr1MAC}]
		#sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceL9 ether://[${rtr1MAC}]
		#sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceL10 ether://[${rtr1MAC}]
		#sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceL11 ether://[${rtr1MAC}]
		#sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceL12 ether://[${rtr1MAC}]
		#sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceL13 ether://[${rtr1MAC}]
		#sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceL14 ether://[${rtr1MAC}]
		#sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceL15 ether://[${rtr1MAC}]
		#sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceL16 ether://[${rtr1MAC}]
		#sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceL17 ether://[${rtr1MAC}]
		#sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceL18 ether://[${rtr1MAC}]
		#sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceL19 ether://[${rtr1MAC}]
		#sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceL20 ether://[${rtr1MAC}]
		sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceOrchestration ether://[${rtr1MAC}]
	fi
fi



sleep 1




if [ ${scenario} == run_4DAG_OrchA ]; then
	if [ ${device} == producer ]; then
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-custom-app-producer /${PREFIX} /sensor 9000 0 100 1000 &
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
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-custom-app-consumer /${PREFIX} ${WORKFLOW_DIR}/4dag.json 1 |& tee ${consumerLog}
	fi
fi

if [ ${scenario} == run_4DAG_OrchB ]; then
	if [ ${device} == producer ]; then
		# start producer application
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-custom-app-producer /${PREFIX} /sensor 9000 0 100 1000 &
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
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-custom-app-consumer /${PREFIX} ${WORKFLOW_DIR}/4dag.json 2 |& tee ${consumerLog}
	fi
fi

if [ ${scenario} == run_4DAG_nesco ] || [ ${scenario} == run_4DAG_nescoSCOPT ]; then
	if [ ${device} == producer ]; then
		# start producer application
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-custom-app-producer /${PREFIX} /sensor 9000 0 100 1000 &
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
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-custom-app-consumer /${PREFIX} ${WORKFLOW_DIR}/4dag.json 0 |& tee ${consumerLog}
	fi
fi

if [ ${scenario} == run_8DAG_OrchA ]; then
	if [ ${device} == producer ]; then
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-custom-app-producer /${PREFIX} /sensor 9000 0 100 1000 &
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
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-custom-app-consumer /${PREFIX} ${WORKFLOW_DIR}/8dag.json 1 |& tee ${consumerLog}
	fi
fi

if [ ${scenario} == run_8DAG_OrchB ]; then
	if [ ${device} == producer ]; then
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-custom-app-producer /${PREFIX} /sensor 9000 0 100 1000 &
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
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-custom-app-consumer /${PREFIX} ${WORKFLOW_DIR}/8dag.json 2 |& tee ${consumerLog}
	fi

fi

if [ ${scenario} == run_8DAG_nesco ] || [ ${scenario} == run_8DAG_nescoSCOPT ]; then
	if [ ${device} == producer ]; then
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-custom-app-producer /${PREFIX} /sensor 9000 0 100 1000 &
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
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-custom-app-consumer /${PREFIX} ${WORKFLOW_DIR}/8dag.json 0 |& tee ${consumerLog}
	fi
fi

if [ ${scenario} == run_8DAG_Caching_OrchA ]; then
	if [ ${device} == producer ]; then
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-custom-app-producer /${PREFIX} /sensor 9000 0 100 1000 &
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
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-custom-app-consumer2 /${PREFIX} ${WORKFLOW_DIR}/4dag-caching.json 1
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-orchestratorA-reset-app /${PREFIX} /serviceOrchestration/reset &
		sleep 1
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-custom-app-consumer /${PREFIX} ${WORKFLOW_DIR}/8dag.json 1 |& tee ${consumerLog}
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
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-custom-app-consumer2 /${PREFIX} ${WORKFLOW_DIR}/4dag-caching.json 2
		sleep 1
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-orchestratorA-reset-app /${PREFIX} /serviceOrchestration/reset &
		sleep 1
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-custom-app-consumer /${PREFIX} ${WORKFLOW_DIR}/8dag.json 2 |& tee ${consumerLog}
	fi
fi

if [ ${scenario} == run_8DAG_Caching_nesco ] || [ ${scenario} == run_8DAG_Caching_nescoSCOPT ]; then
	if [ ${device} == producer ]; then
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-custom-app-producer /${PREFIX} /sensor 9000 0 100 1000 &
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
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-custom-app-consumer2 /${PREFIX} ${WORKFLOW_DIR}/4dag-caching.json 0
		sleep 1
		sleep 1
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-custom-app-consumer /${PREFIX} ${WORKFLOW_DIR}/8dag.json 0 |& tee ${consumerLog}
	fi
fi

if [ ${scenario} == run_20Parallel_OrchA ]; then
	if [ ${device} == producer ]; then
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-custom-app-producer /${PREFIX} /sensor 9000 0 100 1000 &
	fi
	if [ ${device} == rtr1 ]; then
		sleep ${sleepVal}
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
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-custom-app-consumer /${PREFIX} ${WORKFLOW_DIR}/20-parallel.json 1 |& tee ${consumerLog}
	fi
fi

if [ ${scenario} == run_20Parallel_OrchB ]; then
	if [ ${device} == producer ]; then
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-custom-app-producer /${PREFIX} /sensor 9000 0 100 1000 &
	fi
	if [ ${device} == rtr1 ]; then
		sleep ${sleepVal}
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
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-custom-app-consumer /${PREFIX} ${WORKFLOW_DIR}/20-parallel.json 2 |& tee ${consumerLog}
	fi
fi

if [ ${scenario} == run_20Parallel_nesco ] || [ ${scenario} == run_20Parallel_nescoSCOPT ]; then
	if [ ${device} == producer ]; then
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-custom-app-producer /${PREFIX} /sensor 9000 0 100 1000 &
	fi
	if [ ${device} == rtr1 ]; then
		sleep ${sleepVal}
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
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-custom-app-consumer /${PREFIX} ${WORKFLOW_DIR}/20-parallel.json 0 |& tee ${consumerLog}
	fi
fi

if [ ${scenario} == run_20Sensor_OrchA ]; then
	if [ ${device} == producer ]; then
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-custom-app-producer /${PREFIX} /sensor1 9000 0 100 1000 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-custom-app-producer /${PREFIX} /sensor2 9000 0 100 1000 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-custom-app-producer /${PREFIX} /sensor3 9000 0 100 1000 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-custom-app-producer /${PREFIX} /sensor4 9000 0 100 1000 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-custom-app-producer /${PREFIX} /sensor5 9000 0 100 1000 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-custom-app-producer /${PREFIX} /sensor6 9000 0 100 1000 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-custom-app-producer /${PREFIX} /sensor7 9000 0 100 1000 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-custom-app-producer /${PREFIX} /sensor8 9000 0 100 1000 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-custom-app-producer /${PREFIX} /sensor9 9000 0 100 1000 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-custom-app-producer /${PREFIX} /sensor10 9000 0 100 1000 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-custom-app-producer /${PREFIX} /sensor11 9000 0 100 1000 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-custom-app-producer /${PREFIX} /sensor12 9000 0 100 1000 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-custom-app-producer /${PREFIX} /sensor13 9000 0 100 1000 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-custom-app-producer /${PREFIX} /sensor14 9000 0 100 1000 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-custom-app-producer /${PREFIX} /sensor15 9000 0 100 1000 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-custom-app-producer /${PREFIX} /sensor16 9000 0 100 1000 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-custom-app-producer /${PREFIX} /sensor17 9000 0 100 1000 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-custom-app-producer /${PREFIX} /sensor18 9000 0 100 1000 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-custom-app-producer /${PREFIX} /sensor19 9000 0 100 1000 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-custom-app-producer /${PREFIX} /sensor20 9000 0 100 1000 &
	fi
	if [ ${device} == rtr1 ]; then
		sleep ${sleepVal};
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
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-custom-app-consumer /${PREFIX} ${WORKFLOW_DIR}/20-sensor.json 1 |& tee ${consumerLog}
	fi
fi

if [ ${scenario} == run_20Sensor_OrchB ]; then
	if [ ${device} == producer ]; then
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-custom-app-producer /${PREFIX} /sensor1 9000 0 100 1000 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-custom-app-producer /${PREFIX} /sensor2 9000 0 100 1000 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-custom-app-producer /${PREFIX} /sensor3 9000 0 100 1000 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-custom-app-producer /${PREFIX} /sensor4 9000 0 100 1000 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-custom-app-producer /${PREFIX} /sensor5 9000 0 100 1000 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-custom-app-producer /${PREFIX} /sensor6 9000 0 100 1000 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-custom-app-producer /${PREFIX} /sensor7 9000 0 100 1000 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-custom-app-producer /${PREFIX} /sensor8 9000 0 100 1000 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-custom-app-producer /${PREFIX} /sensor9 9000 0 100 1000 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-custom-app-producer /${PREFIX} /sensor10 9000 0 100 1000 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-custom-app-producer /${PREFIX} /sensor11 9000 0 100 1000 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-custom-app-producer /${PREFIX} /sensor12 9000 0 100 1000 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-custom-app-producer /${PREFIX} /sensor13 9000 0 100 1000 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-custom-app-producer /${PREFIX} /sensor14 9000 0 100 1000 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-custom-app-producer /${PREFIX} /sensor15 9000 0 100 1000 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-custom-app-producer /${PREFIX} /sensor16 9000 0 100 1000 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-custom-app-producer /${PREFIX} /sensor17 9000 0 100 1000 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-custom-app-producer /${PREFIX} /sensor18 9000 0 100 1000 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-custom-app-producer /${PREFIX} /sensor19 9000 0 100 1000 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-custom-app-producer /${PREFIX} /sensor20 9000 0 100 1000 &
	fi
	if [ ${device} == rtr1 ]; then
		sleep ${sleepVal};
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
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-custom-app-consumer /${PREFIX} ${WORKFLOW_DIR}/20-sensor.json 2 |& tee ${consumerLog}
	fi
fi

if [ ${scenario} == run_20Sensor_nesco ] || [ ${scenario} == run_20Sensor_nescoSCOPT ]; then
	if [ ${device} == producer ]; then
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-custom-app-producer /${PREFIX} /sensor1 9000 0 100 1000 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-custom-app-producer /${PREFIX} /sensor2 9000 0 100 1000 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-custom-app-producer /${PREFIX} /sensor3 9000 0 100 1000 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-custom-app-producer /${PREFIX} /sensor4 9000 0 100 1000 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-custom-app-producer /${PREFIX} /sensor5 9000 0 100 1000 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-custom-app-producer /${PREFIX} /sensor6 9000 0 100 1000 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-custom-app-producer /${PREFIX} /sensor7 9000 0 100 1000 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-custom-app-producer /${PREFIX} /sensor8 9000 0 100 1000 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-custom-app-producer /${PREFIX} /sensor9 9000 0 100 1000 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-custom-app-producer /${PREFIX} /sensor10 9000 0 100 1000 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-custom-app-producer /${PREFIX} /sensor11 9000 0 100 1000 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-custom-app-producer /${PREFIX} /sensor12 9000 0 100 1000 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-custom-app-producer /${PREFIX} /sensor13 9000 0 100 1000 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-custom-app-producer /${PREFIX} /sensor14 9000 0 100 1000 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-custom-app-producer /${PREFIX} /sensor15 9000 0 100 1000 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-custom-app-producer /${PREFIX} /sensor16 9000 0 100 1000 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-custom-app-producer /${PREFIX} /sensor17 9000 0 100 1000 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-custom-app-producer /${PREFIX} /sensor18 9000 0 100 1000 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-custom-app-producer /${PREFIX} /sensor19 9000 0 100 1000 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-custom-app-producer /${PREFIX} /sensor20 9000 0 100 1000 &
	fi
	if [ ${device} == rtr1 ]; then
		sleep ${sleepVal};
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
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-custom-app-consumer /${PREFIX} ${WORKFLOW_DIR}/20-sensor.json 0 |& tee ${consumerLog}
	fi
fi

if [ ${scenario} == run_20Linear_OrchA ]; then
	if [ ${device} == producer ]; then
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-custom-app-producer /${PREFIX} /sensorL 9000 0 100 1000 &
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
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-custom-app-consumer /${PREFIX} ${WORKFLOW_DIR}/20-linear.json 1 |& tee ${consumerLog}
	fi
fi

if [ ${scenario} == run_20Linear_OrchB ]; then
	if [ ${device} == producer ]; then
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-custom-app-producer /${PREFIX} /sensorL 9000 0 100 1000 &
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
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-custom-app-consumer /${PREFIX} ${WORKFLOW_DIR}/20-linear.json 2 |& tee ${consumerLog}
	fi
fi

if [ ${scenario} == run_20Linear_nesco ] || [ ${scenario} == run_20Linear_nescoSCOPT ]; then
	if [ ${device} == producer ]; then
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-custom-app-producer /${PREFIX} /sensorL 9000 0 100 1000 &
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
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-custom-app-consumer /${PREFIX} ${WORKFLOW_DIR}/20-linear.json 0 |& tee ${consumerLog}
	fi
fi

if [ ${scenario} == run_20Reuse_OrchA ]; then
	if [ ${device} == producer ]; then
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-custom-app-producer /${PREFIX} /sensorL 9000 0 100 1000 &

		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-custom-app-producer /${PREFIX} /sensor1 9000 0 100 1000 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-custom-app-producer /${PREFIX} /sensor2 9000 0 100 1000 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-custom-app-producer /${PREFIX} /sensor3 9000 0 100 1000 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-custom-app-producer /${PREFIX} /sensor4 9000 0 100 1000 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-custom-app-producer /${PREFIX} /sensor5 9000 0 100 1000 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-custom-app-producer /${PREFIX} /sensor6 9000 0 100 1000 &
	fi
	if [ ${device} == rtr1 ]; then
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceA-app /${PREFIX} /serviceL2 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceA-app /${PREFIX} /serviceL6 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceA-app /${PREFIX} /serviceL10 &
	fi
	if [ ${device} == rtr2 ]; then
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceA-app /${PREFIX} /serviceL1 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceA-app /${PREFIX} /serviceL3 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceA-app /${PREFIX} /serviceL5 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceA-app /${PREFIX} /serviceL7 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceA-app /${PREFIX} /serviceL9 &

		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceA-app /${PREFIX} /serviceP1 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceA-app /${PREFIX} /serviceP2 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceA-app /${PREFIX} /serviceP3 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceA-app /${PREFIX} /serviceP4 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceA-app /${PREFIX} /serviceP5 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceA-app /${PREFIX} /serviceP6 &
	fi
	if [ ${device} == rtr3 ]; then
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceA-app /${PREFIX} /serviceL4 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceA-app /${PREFIX} /serviceL8 &

		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceA-app /${PREFIX} /serviceP22 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceA-app /${PREFIX} /serviceP23 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceA-app /${PREFIX} /serviceR1 &
	fi
	if [ ${device} == consumer ]; then
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-orchestratorA-app /${PREFIX} /serviceOrchestration &
		sleep 1
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-custom-app-consumer /${PREFIX} ${WORKFLOW_DIR}/20-reuse.json 1 |& tee ${consumerLog}
	fi
fi

if [ ${scenario} == run_20Reuse_OrchB ]; then
	if [ ${device} == producer ]; then
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-custom-app-producer /${PREFIX} /sensorL 9000 0 100 1000 &

		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-custom-app-producer /${PREFIX} /sensor1 9000 0 100 1000 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-custom-app-producer /${PREFIX} /sensor2 9000 0 100 1000 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-custom-app-producer /${PREFIX} /sensor3 9000 0 100 1000 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-custom-app-producer /${PREFIX} /sensor4 9000 0 100 1000 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-custom-app-producer /${PREFIX} /sensor5 9000 0 100 1000 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-custom-app-producer /${PREFIX} /sensor6 9000 0 100 1000 &
	fi
	if [ ${device} == rtr1 ]; then
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceB-app /${PREFIX} /serviceL2 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceB-app /${PREFIX} /serviceL6 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceB-app /${PREFIX} /serviceL10 &
	fi
	if [ ${device} == rtr2 ]; then
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceB-app /${PREFIX} /serviceL1 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceB-app /${PREFIX} /serviceL3 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceB-app /${PREFIX} /serviceL5 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceB-app /${PREFIX} /serviceL7 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceB-app /${PREFIX} /serviceL9 &

		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceB-app /${PREFIX} /serviceP1 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceB-app /${PREFIX} /serviceP2 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceB-app /${PREFIX} /serviceP3 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceB-app /${PREFIX} /serviceP4 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceB-app /${PREFIX} /serviceP5 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceB-app /${PREFIX} /serviceP6 &
	fi
	if [ ${device} == rtr3 ]; then
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceB-app /${PREFIX} /serviceL4 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceB-app /${PREFIX} /serviceL8 &

		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceB-app /${PREFIX} /serviceP22 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceB-app /${PREFIX} /serviceP23 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceB-app /${PREFIX} /serviceR1 &
	fi
	if [ ${device} == consumer ]; then
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-orchestratorB-app /${PREFIX} /serviceOrchestration &
		sleep 1
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-custom-app-consumer /${PREFIX} ${WORKFLOW_DIR}/20-reuse.json 2 |& tee ${consumerLog}
	fi
fi

if [ ${scenario} == run_20Reuse_nesco ] || [ ${scenario} == run_20Reuse_nescoSCOPT ]; then
	if [ ${device} == producer ]; then
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-custom-app-producer /${PREFIX} /sensorL 9000 0 100 1000 &

		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-custom-app-producer /${PREFIX} /sensor1 9000 0 100 1000 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-custom-app-producer /${PREFIX} /sensor2 9000 0 100 1000 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-custom-app-producer /${PREFIX} /sensor3 9000 0 100 1000 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-custom-app-producer /${PREFIX} /sensor4 9000 0 100 1000 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-custom-app-producer /${PREFIX} /sensor5 9000 0 100 1000 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-custom-app-producer /${PREFIX} /sensor6 9000 0 100 1000 &
	fi
	if [ ${device} == rtr1 ]; then
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-forwarder-app /${PREFIX} /serviceL2 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-forwarder-app /${PREFIX} /serviceL6 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-forwarder-app /${PREFIX} /serviceL10 &
	fi
	if [ ${device} == rtr2 ]; then
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-forwarder-app /${PREFIX} /serviceL1 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-forwarder-app /${PREFIX} /serviceL3 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-forwarder-app /${PREFIX} /serviceL5 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-forwarder-app /${PREFIX} /serviceL7 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-forwarder-app /${PREFIX} /serviceL9 &

		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-forwarder-app /${PREFIX} /serviceP1 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-forwarder-app /${PREFIX} /serviceP2 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-forwarder-app /${PREFIX} /serviceP3 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-forwarder-app /${PREFIX} /serviceP4 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-forwarder-app /${PREFIX} /serviceP5 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-forwarder-app /${PREFIX} /serviceP6 &
	fi
	if [ ${device} == rtr3 ]; then
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-forwarder-app /${PREFIX} /serviceL4 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-forwarder-app /${PREFIX} /serviceL8 &

		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-forwarder-app /${PREFIX} /serviceP22 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-forwarder-app /${PREFIX} /serviceP23 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-forwarder-app /${PREFIX} /serviceR1 &
	fi
	if [ ${device} == consumer ]; then
		sleep 1
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-custom-app-consumer /${PREFIX} ${WORKFLOW_DIR}/20-reuse.json 0 |& tee ${consumerLog}
	fi
fi

if [ ${scenario} == run_20Scramble_OrchA ]; then
	if [ ${device} == producer ]; then
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-custom-app-producer /${PREFIX} /sensorL 9000 0 100 1000 &
	fi
	if [ ${device} == rtr1 ]; then
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceA-app /${PREFIX} /serviceL1 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceA-app /${PREFIX} /serviceL4 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceA-app /${PREFIX} /serviceL8 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceA-app /${PREFIX} /serviceL12 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceA-app /${PREFIX} /serviceL14 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceA-app /${PREFIX} /serviceL16 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceA-app /${PREFIX} /serviceL18 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceA-app /${PREFIX} /serviceL20 &
	fi
	if [ ${device} == rtr2 ]; then
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceA-app /${PREFIX} /serviceL2 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceA-app /${PREFIX} /serviceL5 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceA-app /${PREFIX} /serviceL7 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceA-app /${PREFIX} /serviceL9 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceA-app /${PREFIX} /serviceL11 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceA-app /${PREFIX} /serviceL13 &
	fi
	if [ ${device} == rtr3 ]; then
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceA-app /${PREFIX} /serviceL3 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceA-app /${PREFIX} /serviceL6 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceA-app /${PREFIX} /serviceL10 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceA-app /${PREFIX} /serviceL15 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceA-app /${PREFIX} /serviceL17 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceA-app /${PREFIX} /serviceL19 &
	fi
	if [ ${device} == consumer ]; then
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-orchestratorA-app /${PREFIX} /serviceOrchestration &
		sleep 1
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-custom-app-consumer /${PREFIX} ${WORKFLOW_DIR}/20-linear.json 1
	fi
fi

if [ ${scenario} == run_20Scramble_OrchB ]; then
	if [ ${device} == producer ]; then
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-custom-app-producer /${PREFIX} /sensorL 9000 0 100 1000 &
	fi
	if [ ${device} == rtr1 ]; then
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceB-app /${PREFIX} /serviceL1 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceB-app /${PREFIX} /serviceL4 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceB-app /${PREFIX} /serviceL8 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceB-app /${PREFIX} /serviceL12 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceB-app /${PREFIX} /serviceL14 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceB-app /${PREFIX} /serviceL16 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceB-app /${PREFIX} /serviceL18 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceB-app /${PREFIX} /serviceL20 &
	fi
	if [ ${device} == rtr2 ]; then
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceB-app /${PREFIX} /serviceL2 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceB-app /${PREFIX} /serviceL5 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceB-app /${PREFIX} /serviceL7 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceB-app /${PREFIX} /serviceL9 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceB-app /${PREFIX} /serviceL11 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceB-app /${PREFIX} /serviceL13 &
	fi
	if [ ${device} == rtr3 ]; then
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceB-app /${PREFIX} /serviceL3 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceB-app /${PREFIX} /serviceL6 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceB-app /${PREFIX} /serviceL10 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceB-app /${PREFIX} /serviceL15 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceB-app /${PREFIX} /serviceL17 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceB-app /${PREFIX} /serviceL19 &
	fi
	if [ ${device} == consumer ]; then
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-orchestratorB-app /${PREFIX} /serviceOrchestration &
		sleep 1
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-custom-app-consumer /${PREFIX} ${WORKFLOW_DIR}/20-linear.json 2 |& tee ${consumerLog}
	fi
fi

if [ ${scenario} == run_20Scramble_nesco ] || [ ${scenario} == run_20Scramble_nescoSCOPT ]; then
	if [ ${device} == producer ]; then
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-custom-app-producer /${PREFIX} /sensorL 9000 0 100 1000 &
	fi
	if [ ${device} == rtr1 ]; then
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-forwarder-app /${PREFIX} /serviceL1 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-forwarder-app /${PREFIX} /serviceL4 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-forwarder-app /${PREFIX} /serviceL8 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-forwarder-app /${PREFIX} /serviceL12 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-forwarder-app /${PREFIX} /serviceL14 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-forwarder-app /${PREFIX} /serviceL16 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-forwarder-app /${PREFIX} /serviceL18 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-forwarder-app /${PREFIX} /serviceL20 &
	fi
	if [ ${device} == rtr2 ]; then
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-forwarder-app /${PREFIX} /serviceL2 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-forwarder-app /${PREFIX} /serviceL5 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-forwarder-app /${PREFIX} /serviceL7 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-forwarder-app /${PREFIX} /serviceL9 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-forwarder-app /${PREFIX} /serviceL11 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-forwarder-app /${PREFIX} /serviceL13 &
	fi
	if [ ${device} == rtr3 ]; then
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-forwarder-app /${PREFIX} /serviceL3 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-forwarder-app /${PREFIX} /serviceL6 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-forwarder-app /${PREFIX} /serviceL10 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-forwarder-app /${PREFIX} /serviceL15 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-forwarder-app /${PREFIX} /serviceL17 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-forwarder-app /${PREFIX} /serviceL19 &
	fi
	if [ ${device} == consumer ]; then
		sleep 1
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-custom-app-consumer /${PREFIX} ${WORKFLOW_DIR}/20-linear.json 0 |& tee ${consumerLog}
	fi
fi










# stop NFD to clear cache and forwarding table entries
if [ ${device} == consumer ]; then
	nfd-stop
fi



