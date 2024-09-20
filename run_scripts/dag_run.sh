#! /bin/bash


#----- THIS ONLY NEEDS TO BE RUN ONCE --------------------
#cd ~/ndn/ndn-cxx
#./waf clean
#./waf
#sudo ./waf install
#nfd-start
#---------------------------------------------------------

scenario=run_4DAG_OrchA
#scenario=run_4DAG_OrchB
#scenario=run_4DAG_nesco
#scenario=run_8DAG_OrchA
#scenario=run_8DAG_OrchB
#scenario=run_8DAG_nesco
#scenario=run_8DAG_Caching_OrchA
#scenario=run_8DAG_Caching_OrchB
#scenario=run_8DAG_Caching_nesco
#scenario=run_20Parallel_OrchA
#scenario=run_20Parallel_OrchB
#scenario=run_20Parallel_nesco
#scenario=run_20Sensor_OrchA
#scenario=run_20Sensor_OrchB
#scenario=run_20Sensor_nesco
#scenario=run_20Linear_OrchA
#scenario=run_20Linear_OrchB
#scenario=run_20Linear_nesco

PREFIX=orchA
#PREFIX=orchB
#PREFIX=nesco
#PREFIX=nescoSCOPT

sleep=0.1






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


clear


# to run <command> remotely:
#ssh <username>@<ip_address> "nohup <command> >/dev/null 2>/dev/null </dev/null &"
# or
#ssh <username>@<ip_address> "<command> >/dev/null 2>&1 &"

ssh ${username}@${producerWiFiIP} "~/ndn/ndn-cxx/run_scripts/dag_run_local.sh producer ${scenario} ${PREFIX} ${sleep} >/dev/null 2>&1 &"
ssh ${username}@${rtr1WiFiIP} "~/ndn/ndn-cxx/run_scripts/dag_run_local.sh rtr1 ${scenario} ${PREFIX} ${sleep} >/dev/null 2>&1 &"
ssh ${username}@${rtr2WiFiIP} "~/ndn/ndn-cxx/run_scripts/dag_run_local.sh rtr2 ${scenario} ${PREFIX} ${sleep} >/dev/null 2>&1 &"
ssh ${username}@${rtr3WiFiIP} "~/ndn/ndn-cxx/run_scripts/dag_run_local.sh rtr3 ${scenario} ${PREFIX} ${sleep} >/dev/null 2>&1 &"
sleep 1
ssh ${username}@${consumerWiFiIP} "~/ndn/ndn-cxx/run_scripts/dag_run_local.sh consumer ${scenario} ${PREFIX} ${sleep} >/dev/null 2>&1 &"


