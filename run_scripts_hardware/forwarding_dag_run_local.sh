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


NDN_DIR="$HOME/ndn"
RUN_DIR="$NDN_DIR/ndn-cxx/run_scripts"
WORKFLOW_DIR="$NDN_DIR/ndn-cxx/run_scripts/workflows"

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
	sleep ${sleepVal}; nfdc face create remote ether://[${rtr2MAC}] local dev://${producerinterface} persistency permanent
fi
if [ ${device} == rtr1 ]; then
	echo -en "Creating faces for rtr1\r\n"
	sleep ${sleepVal}; nfdc face create remote ether://[${producerMAC}] local dev://${rtr1interface} persistency permanent
	sleep ${sleepVal}; nfdc face create remote ether://[${rtr3MAC}] local dev://${rtr1interface} persistency permanent
fi
if [ ${device} == rtr2 ]; then
	echo -en "Creating faces for rtr2\r\n"
	sleep ${sleepVal}; nfdc face create remote ether://[${producerMAC}] local dev://${rtr2interface} persistency permanent
	sleep ${sleepVal}; nfdc face create remote ether://[${rtr3MAC}] local dev://${rtr2interface} persistency permanent
fi
if [ ${device} == rtr3 ]; then
	echo -en "Creating faces for rtr3\r\n"
	sleep ${sleepVal}; nfdc face create remote ether://[${rtr1MAC}] local dev://${rtr3interface} persistency permanent
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
	[ ${scenario} == run_20Scramble_OrchA ]; then
		PREFIX=OrchA
fi
if 	[ ${scenario} == run_4DAG_OrchB ] || \
	[ ${scenario} == run_8DAG_OrchB ] || \
	[ ${scenario} == run_8DAG_Caching_OrchB ] || \
	[ ${scenario} == run_20Parallel_OrchB ] || \
	[ ${scenario} == run_20Sensor_OrchB ] || \
	[ ${scenario} == run_20Linear_OrchB ] || \
	[ ${scenario} == run_20Scramble_OrchB ]; then
		PREFIX=OrchB
fi
if 	[ ${scenario} == run_4DAG_nesco ] || \
	[ ${scenario} == run_8DAG_nesco ] || \
	[ ${scenario} == run_8DAG_Caching_nesco ] || \
	[ ${scenario} == run_20Parallel_nesco ] || \
	[ ${scenario} == run_20Sensor_nesco ] || \
	[ ${scenario} == run_20Linear_nesco ] || \
	[ ${scenario} == run_20Scramble_nesco ]; then
		PREFIX=nesco
fi
if 	[ ${scenario} == run_4DAG_nescoSCOPT ] || \
	[ ${scenario} == run_8DAG_nescoSCOPT ] || \
	[ ${scenario} == run_8DAG_Caching_nescoSCOPT ] || \
	[ ${scenario} == run_20Parallel_nescoSCOPT ] || \
	[ ${scenario} == run_20Sensor_nescoSCOPT ] || \
	[ ${scenario} == run_20Linear_nescoSCOPT ] || \
	[ ${scenario} == run_20Scramble_nescoSCOPT ]; then
		PREFIX=nescoSCOPT
fi


# add STATIC routes for all the PREFIXes to all nodes
if false; then
	if 	[ ${scenario} == run_4DAG_OrchA ] || \
		[ ${scenario} == run_4DAG_OrchB ] || \
		[ ${scenario} == run_4DAG_nesco ] || \
		[ ${scenario} == run_4DAG_nescoSCOPT ]; then
		echo -en "4DAG scenario\r\n"
		if [ ${device} == consumer ]; then
			echo -en "Setting up routes for the consumer\r\n"
			sleep ${sleepVal}; nfdc route add /${PREFIX}/sensor ether://[${rtr3MAC}] cost 3
			sleep ${sleepVal}; nfdc route add /${PREFIX}/sensor ether://[${rtr3MAC}] cost 3
			sleep ${sleepVal}; nfdc route add /${PREFIX}/service1 ether://[${rtr3MAC}] cost 1
			sleep ${sleepVal}; nfdc route add /${PREFIX}/service2 ether://[${rtr3MAC}] cost 2
			sleep ${sleepVal}; nfdc route add /${PREFIX}/service3 ether://[${rtr3MAC}] cost 2
			sleep ${sleepVal}; nfdc route add /${PREFIX}/service4 ether://[${rtr3MAC}] cost 2
			#sleep ${sleepVal}; nfdc route add /${PREFIX}/serviceOrchestration ether://[${consumerMAC}]
		fi
		
		if [ ${device} == rtr3 ]; then
			echo -en "Setting up routes for rtr3\r\n"
			sleep ${sleepVal}; nfdc route add /${PREFIX}/sensor ether://[${rtr1MAC}] cost 2
			sleep ${sleepVal}; nfdc route add /${PREFIX}/sensor ether://[${rtr2MAC}] cost 3
			sleep ${sleepVal}; nfdc route add /${PREFIX}/service1 ether://[${rtr3MAC}] cost 0
			sleep ${sleepVal}; nfdc route add /${PREFIX}/service1 ether://[${rtr1MAC}] cost 2
			sleep ${sleepVal}; nfdc route add /${PREFIX}/service1 ether://[${rtr2MAC}] cost 3
			sleep ${sleepVal}; nfdc route add /${PREFIX}/service2 ether://[${rtr1MAC}] cost 1
			sleep ${sleepVal}; nfdc route add /${PREFIX}/service2 ether://[${rtr2MAC}] cost 4
			sleep ${sleepVal}; nfdc route add /${PREFIX}/service3 ether://[${rtr1MAC}] cost 1
			sleep ${sleepVal}; nfdc route add /${PREFIX}/service3 ether://[${rtr2MAC}] cost 1
			sleep ${sleepVal}; nfdc route add /${PREFIX}/service4 ether://[${rtr2MAC}] cost 1
			sleep ${sleepVal}; nfdc route add /${PREFIX}/service4 ether://[${rtr1MAC}] cost 4
		fi
	
		if [ ${device} == rtr2 ]; then
			echo -en "Setting up routes for rtr2\r\n"
			sleep ${sleepVal}; nfdc route add /${PREFIX}/sensor ether://[${producerMAC}] cost 2
			sleep ${sleepVal}; nfdc route add /${PREFIX}/sensor ether://[${rtr3MAC}] cost 3
			sleep ${sleepVal}; nfdc route add /${PREFIX}/service1 ether://[${rtr3MAC}] cost 1
			sleep ${sleepVal}; nfdc route add /${PREFIX}/service1 ether://[${producerMAC}] cost 2
			sleep ${sleepVal}; nfdc route add /${PREFIX}/service2 ether://[${rtr3MAC}] cost 2
			sleep ${sleepVal}; nfdc route add /${PREFIX}/service2 ether://[${producerMAC}] cost 3
			sleep ${sleepVal}; nfdc route add /${PREFIX}/service3 ether://[${rtr2MAC}] cost 0
			sleep ${sleepVal}; nfdc route add /${PREFIX}/service3 ether://[${producerMAC}] cost 3
			sleep ${sleepVal}; nfdc route add /${PREFIX}/service3 ether://[${rtr3MAC}] cost 2
			sleep ${sleepVal}; nfdc route add /${PREFIX}/service4 ether://[${rtr2MAC}] cost 0
		fi
	
		if [ ${device} == rtr1 ]; then
			echo -en "Setting up routes for rtr1\r\n"
			sleep ${sleepVal}; nfdc route add /${PREFIX}/sensor ether://[${producerMAC}] cost 1
			sleep ${sleepVal}; nfdc route add /${PREFIX}/sensor ether://[${rtr3MAC}] cost 4
			sleep ${sleepVal}; nfdc route add /${PREFIX}/service1 ether://[$producerMAC}] cost 1
			sleep ${sleepVal}; nfdc route add /${PREFIX}/service1 ether://[${rtr3MAC}] cost 1
			sleep ${sleepVal}; nfdc route add /${PREFIX}/service2 ether://[${rtr1MAC}] cost 0
			sleep ${sleepVal}; nfdc route add /${PREFIX}/service3 ether://[${rtr1MAC}] cost 0
			sleep ${sleepVal}; nfdc route add /${PREFIX}/service3 ether://[${producerMAC}] cost 3
			sleep ${sleepVal}; nfdc route add /${PREFIX}/service3 ether://[${rtr3MAC}] cost 2
			sleep ${sleepVal}; nfdc route add /${PREFIX}/service4 ether://[${rtr3MAC}] cost 2
			sleep ${sleepVal}; nfdc route add /${PREFIX}/service4 ether://[${producerMAC}] cost 3
		fi
	
		if [ ${device} == producer ]; then
			echo -en "Setting up routes for rtr3\r\n"
			sleep ${sleepVal}; nfdc route add /${PREFIX}/sensor ether://[${producerMAC}] cost 0
			sleep ${sleepVal}; nfdc route add /${PREFIX}/service1 ether://[${producerMAC}] cost 0
			sleep ${sleepVal}; nfdc route add /${PREFIX}/service1 ether://[${rtr1MAC}] cost 2
			sleep ${sleepVal}; nfdc route add /${PREFIX}/service1 ether://[${rtr2MAC}] cost 3
			sleep ${sleepVal}; nfdc route add /${PREFIX}/service2 ether://[${rtr1MAC}] cost 1
			sleep ${sleepVal}; nfdc route add /${PREFIX}/service2 ether://[${rtr2MAC}] cost 4
			sleep ${sleepVal}; nfdc route add /${PREFIX}/service3 ether://[${rtr1MAC}] cost 1
			sleep ${sleepVal}; nfdc route add /${PREFIX}/service3 ether://[${rtr2MAC}] cost 2
			sleep ${sleepVal}; nfdc route add /${PREFIX}/service4 ether://[${rtr2MAC}] cost 2
			sleep ${sleepVal}; nfdc route add /${PREFIX}/service4 ether://[${rtr1MAC}] cost 3
		fi
	fi
fi




sleep 1




if [ ${scenario} == run_4DAG_nesco ] || [ ${scenario} == run_4DAG_nescoSCOPT ]; then
	if [ ${device} == producer ]; then
		# start producer application
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-custom-app-producer /${PREFIX} /sensor &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-forwarder-app /${PREFIX} /service1 &
		sleep ${sleepVal}; sudo nlsr -f ~/ndn/NLSR/nlsr-producer.conf
	fi
	if [ ${device} == rtr1 ]; then
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-forwarder-app /${PREFIX} /service2 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-forwarder-app /${PREFIX} /service3 &
		sleep ${sleepVal}; sudo nlsr -f ~/ndn/NLSR/nlsr-rtr1.conf
	fi
	if [ ${device} == rtr2 ]; then
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-forwarder-app /${PREFIX} /service3 &
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-forwarder-app /${PREFIX} /service4 &
		sleep ${sleepVal}; sudo nlsr -f ~/ndn/NLSR/nlsr-rtr2.conf
	fi
	if [ ${device} == rtr3 ]; then
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-dag-forwarder-app /${PREFIX} /service1 &
		sleep ${sleepVal}; sudo nlsr -f ~/ndn/NLSR/nlsr-rtr3.conf
	fi
	if [ ${device} == consumer ]; then
		sleep ${sleepVal}; sudo nlsr -f ~/ndn/NLSR/nlsr-consumer.conf
		sleep 30
		# start consumer application (not in the background, so that we see the final print statements)
		sleep ${sleepVal}; ~/ndn/ndn-cxx/build/examples/cabeee-custom-app-consumer /${PREFIX} ${WORKFLOW_DIR}/4dag.json 0
	fi
fi












# stop NFD to clear cache and forwarding table entries
#if [ ${device} == consumer ]; then
	#nfd-stop
#fi



