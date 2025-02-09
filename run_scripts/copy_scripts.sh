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
rpi5rtr1ETHMAC=2c:cf:67:4d:af:4a
rpi5rtr1WiFiMAC=2c:cf:67:4d:af:4b
rpi5rtr1ETHMAC=2c:cf:67:4d:af:02
rpi5rtr1WiFiMAC=2c:cf:67:4d:af:03
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



scp ~/ndn/ndn-cxx/run_scripts/*.sh ${username}@${rpi5producerWiFiIP}:~/ndn/ndn-cxx/run_scripts/
scp ~/ndn/ndn-cxx/run_scripts/*.sh ${username}@${rpi5rtr1WiFiIP}:~/ndn/ndn-cxx/run_scripts/
scp ~/ndn/ndn-cxx/run_scripts/*.sh ${username}@${rpi5rtr2WiFiIP}:~/ndn/ndn-cxx/run_scripts/
scp ~/ndn/ndn-cxx/run_scripts/*.sh ${username}@${rpi5rtr3WiFiIP}:~/ndn/ndn-cxx/run_scripts/


#scp ~/ndn/ndn-cxx/run_scripts/workflows/* ${username}@${producerWiFiIP}:~/ndn/ndn-cxx/run_scripts/workflows/
#scp ~/ndn/ndn-cxx/run_scripts/workflows/* ${username}@${rtr1WiFiIP}:~/ndn/ndn-cxx/run_scripts/workflows/
#scp ~/ndn/ndn-cxx/run_scripts/workflows/* ${username}@${rtr2WiFiIP}:~/ndn/ndn-cxx/run_scripts/workflows/
#scp ~/ndn/ndn-cxx/run_scripts/workflows/* ${username}@${rtr3WiFiIP}:~/ndn/ndn-cxx/run_scripts/workflows/



scp ~/ndn/NLSR/nlsr*.conf ${username}@${rpi5producerWiFiIP}:~/ndn/NLSR/
scp ~/ndn/NLSR/nlsr*.conf ${username}@${rpi5rtr1WiFiIP}:~/ndn/NLSR/
scp ~/ndn/NLSR/nlsr*.conf ${username}@${rpi5rtr2WiFiIP}:~/ndn/NLSR/
scp ~/ndn/NLSR/nlsr*.conf ${username}@${rpi5rtr3WiFiIP}:~/ndn/NLSR/
