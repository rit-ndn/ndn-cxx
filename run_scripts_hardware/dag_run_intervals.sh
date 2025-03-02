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



#scenario=run_4DAG_OrchA
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

#PREFIX=orchA
#PREFIX=orchB
#PREFIX=nesco
#PREFIX=nescoSCOPT

sleep=0.2


clear


# to run <command> remotely:
#ssh <username>@<ip_address> "nohup <command> >/dev/null 2>/dev/null </dev/null &"
# or
#ssh <username>@<ip_address> "<command> >/dev/null 2>&1 &"

#ssh ${username}@${rpi5producerWiFiIP} "~/ndn/ndn-cxx/run_scripts_hardware/dag_run_local_intervals.sh producer ${scenario} ${PREFIX} ${sleep} >/dev/null 2>&1 &"
#ssh ${username}@${rpi5rtr1WiFiIP}     "~/ndn/ndn-cxx/run_scripts_hardware/dag_run_local_intervals.sh rtr1     ${scenario} ${PREFIX} ${sleep} >/dev/null 2>&1 &"
#ssh ${username}@${rpi5rtr2WiFiIP}     "~/ndn/ndn-cxx/run_scripts_hardware/dag_run_local_intervals.sh rtr2     ${scenario} ${PREFIX} ${sleep} >/dev/null 2>&1 &"
#ssh ${username}@${rpi5rtr3WiFiIP}     "~/ndn/ndn-cxx/run_scripts_hardware/dag_run_local_intervals.sh rtr3     ${scenario} ${PREFIX} ${sleep} >/dev/null 2>&1 &"
#sleep 20
#ssh ${username}@${rpi5consumerWiFiIP} "~/ndn/ndn-cxx/run_scripts_hardware/dag_run_local_intervals.sh consumer ${scenario} ${PREFIX} ${sleep}"






set -e


changeLinkDelay=0
linkDelayMS=0.9

numSamples=1
poissonRate=10
poissonTotal=100

NDN_DIR="$HOME/ndn"
RUN_DIR="$NDN_DIR/ndn-cxx/run_scripts_hardware"
WORKFLOW_DIR="$RUN_DIR/workflows"
TOPOLOGY_DIR="$RUN_DIR/topologies"

declare -a scenarios=(
	# 20 Sensor (using 3node topology)
	"run_intervals_20Sensor_OrchA orchA 20-sensor.json 20-sensor-in3node.hosting topo-cabeee-3node.txt"
####"run_intervals_20Sensor_OrchB orchB 20-sensor.json 20-sensor-in3node.hosting topo-cabeee-3node.txt"
	"run_intervals_20Sensor_nesco nesco 20-sensor.json 20-sensor-in3node.hosting topo-cabeee-3node.txt"
	"run_intervals_20Sensor_nescoSCOPT nescoSCOPT 20-sensor.json 20-sensor-in3node.hosting topo-cabeee-3node.txt"
# 20 Linear (using 3node topology)
	"run_intervals_20Linear_OrchA orchA 20-linear.json 20-linear-in3node.hosting topo-cabeee-3node.txt"
####"run_intervals_20Linear_OrchB orchB 20-linear.json 20-linear-in3node.hosting topo-cabeee-3node.txt"
	"run_intervals_20Linear_nesco nesco 20-linear.json 20-linear-in3node.hosting topo-cabeee-3node.txt"
	"run_intervals_20Linear_nescoSCOPT nescoSCOPT 20-linear.json 20-linear-in3node.hosting topo-cabeee-3node.txt"
# 20 Scramble (using 3node topology)
	"run_intervals_20Scramble_OrchA orchA 20-linear.json 20-scramble-in3node.hosting topo-cabeee-3node.txt"
####"run_intervals_20Scramble_OrchB orchB 20-linear.json 20-scramble-in3node.hosting topo-cabeee-3node.txt"
	"run_intervals_20Scramble_nesco nesco 20-linear.json 20-scramble-in3node.hosting topo-cabeee-3node.txt"
	"run_intervals_20Scramble_nescoSCOPT nescoSCOPT 20-linear.json 20-scramble-in3node.hosting topo-cabeee-3node.txt"
)

consumerLog="$RUN_DIR/cabeee_consumer.log"
csv_out="$RUN_DIR/perf-results-hardware_intervals.csv"
header="Example, Min Service Latency(s), Low Quartile Service Latency(s), Mid Quartile Service Latency(s), High Quartile Service Latency(s), Max Service Latency(s), Total Service Latency(s), Avg Service Latency(s), Requests Fulfilled, Final Result, Time, ndn-cxx commit, NFD commit, NLSR commit"

if [ ! -f "$csv_out" ]; then
	echo "Creating csv..."
	echo "$header" > "$csv_out"
elif ! grep -q -F "$header" "$csv_out"; then
	echo -en "Overwriting csv...\r\n"
	mv "$csv_out" "$csv_out.bak"
	echo "$header" > "$csv_out"
else
	echo "Updating csv..."
	cp "$csv_out" "$csv_out.bak"
fi

if [ ! -f "$consumerLog" ]; then
	echo "Creating consumer log file"
else
	echo "Creating backup of existing consumer log file"
	mv "$consumerLog" "$consumerLog.bak"
fi

for iterator in "${scenarios[@]}"
do
	read -a itrArray <<< "$iterator" #default whitespace IFS
	scenario=${itrArray[0]}
	type=${itrArray[1]}
	wf=${WORKFLOW_DIR}/${itrArray[2]}
	hosting=${WORKFLOW_DIR}/${itrArray[3]}
	topo=${TOPOLOGY_DIR}/${itrArray[4]}
	echo -en "Scenario: $scenario\r\n"
	echo -en "type: $type\r\n"
	echo -en "Workflow: $wf\r\n"
	echo -en "Hosting: $hosting\r\n"
	echo -en "Topology: $topo\r\n"


	for sample in $(seq 1 $numSamples);
	do
		now="$(date -Iseconds)"

		ndncxx_hash="$(git -C "$NDN_DIR/ndn-cxx" rev-parse HEAD)"
		nfd_hash="$(git -C "$NDN_DIR/NFD" rev-parse HEAD)"
		nlsr_hash="$(git -C "$NDN_DIR/NLSR" rev-parse HEAD)"

		# these sed scripts depend on the order in which the logs are printed

		echo -e "   Running sample #${sample}..."

		ssh ${username}@${rpi5producerWiFiIP} "~/ndn/ndn-cxx/run_scripts_hardware/dag_run_local_intervals.sh producer ${scenario} ${sleep} ${changeLinkDelay} ${linkDelayMS} ${consumerLog} ${poissonRate} ${poissonTotal} >/dev/null 2>&1 &"
		ssh ${username}@${rpi5rtr1WiFiIP}     "~/ndn/ndn-cxx/run_scripts_hardware/dag_run_local_intervals.sh rtr1     ${scenario} ${sleep} ${changeLinkDelay} ${linkDelayMS} ${consumerLog} ${poissonRate} ${poissonTotal} >/dev/null 2>&1 &"
		ssh ${username}@${rpi5rtr2WiFiIP}     "~/ndn/ndn-cxx/run_scripts_hardware/dag_run_local_intervals.sh rtr2     ${scenario} ${sleep} ${changeLinkDelay} ${linkDelayMS} ${consumerLog} ${poissonRate} ${poissonTotal} >/dev/null 2>&1 &"
		ssh ${username}@${rpi5rtr3WiFiIP}     "~/ndn/ndn-cxx/run_scripts_hardware/dag_run_local_intervals.sh rtr3     ${scenario} ${sleep} ${changeLinkDelay} ${linkDelayMS} ${consumerLog} ${poissonRate} ${poissonTotal} >/dev/null 2>&1 &"
		sleep 20
		cmd="$HOME/ndn/ndn-cxx/run_scripts_hardware/dag_run_local_intervals.sh consumer ${scenario} ${sleep} ${changeLinkDelay} ${linkDelayMS} ${consumerLog} ${poissonRate} ${poissonTotal}"

		${cmd} |& tee /dev/tty


		latencies=$( \
			python3 process_nfd_logs_intervals.py "$consumerLog" | sed -n \
			-e 's/^\s*consumer min latency: \([0-9\.]*\) seconds$/\1,/p' \
			-e 's/^\s*consumer low latency: \([0-9\.]*\) seconds$/\1,/p' \
			-e 's/^\s*consumer mid latency: \([0-9\.]*\) seconds$/\1,/p' \
			-e 's/^\s*consumer high latency: \([0-9\.]*\) seconds$/\1,/p' \
			-e 's/^\s*consumer max latency: \([0-9\.]*\) seconds$/\1,/p' \
			-e 's/^\s*consumer total latency: \([0-9\.]*\) seconds$/\1,/p' \
			-e 's/^\s*consumer avg latency: \([0-9\.]*\) seconds$/\1,/p' \
			-e 's/^\s*consumer requests fulfilled: \([0-9\.]*\) total requests$/\1,/p' \
			-e 's/^\s*consumer Final answer: \([0-9\.]*\) numerical$/\1,/p' \
			| tr -d '\n' \
		)
		min_latency="$(echo "$latencies" | cut -d',' -f1)"
		low_latency="$(echo "$latencies" | cut -d',' -f2)"
		mid_latency="$(echo "$latencies" | cut -d',' -f3)"
		high_latency="$(echo "$latencies" | cut -d',' -f4)"
		max_latency="$(echo "$latencies" | cut -d',' -f5)"
		total_latency="$(echo "$latencies" | cut -d',' -f6)"
		avg_latency="$(echo "$latencies" | cut -d',' -f7)"
		requests_fulfilled="$(echo "$latencies" | cut -d',' -f8)"
		final_answer="$(echo "$latencies" | cut -d',' -f9)"



		#sleep 0.1
		#ssh ${username}@${producerWiFiIP} "nfd-stop"
		#ssh ${username}@${rpi5rtr1WiFiIP}     "nfd-stop"
		#ssh ${username}@${rpi5rtr2WiFiIP}     "nfd-stop"
		#ssh ${username}@${rpi5rtr3WiFiIP}     "nfd-stop"
		#nfd-stop

		row="$scenario, $min_latency, $low_latency, $mid_latency, $high_latency, $max_latency, $total_latency, $avg_latency, $requests_fulfilled, $final_answer, $now, $ndncxx_hash, $nfd_hash, $nlsr_hash"

		echo -en "   Dumping to csv...\r\n"
		# replace existing line
		line_num="$(grep -n -F "$scenario," "$csv_out" | cut -d: -f1 | head -1)"
		if [ -n "$line_num" ]; then
			sed --in-place -e "${line_num}c\\$row" "$csv_out"
		else
			echo "$row" >> "$csv_out"
		fi
		# don't replace, just add this run to the bottom of the file
		#echo "$row" >> "$csv_out"

		echo ""
	done
done

echo -en "All examples ran\r\n"
