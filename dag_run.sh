#! /bin/bash


#----- THIS ONLY NEEDS TO BE RUN ONCE --------------------
#cd ~/ndn/ndn-cxx
#./waf clean
#./waf
#sudo ./waf install
#nfd-start
#---------------------------------------------------------


#clear


# to run <command> remotely:
#ssh cabeee@<ip_address> 'nohup <command> >/dev/null 2>/dev/null </dev/null &'
# or
#ssh cabeee@<ip_address> '<command> >/dev/null 2>&1 &'


# start NFD on all devices
#ssh cabeee@192.168.20.144 'nohup nfd-start >/dev/null 2>/dev/null </dev/null &'
#ssh cabeee@192.168.20.151 'nohup nfd-start >/dev/null 2>/dev/null </dev/null &'
#ssh cabeee@192.168.20.147 'nohup nfd-start >/dev/null 2>/dev/null </dev/null &'
#ssh cabeee@192.168.20.144 'nfd-start >/dev/null 2>&1 &'
#ssh cabeee@192.168.20.151 'nfd-start >/dev/null 2>&1 &'
#ssh cabeee@192.168.20.147 'nfd-start >/dev/null 2>&1 &'


# add routes for all the PREFIXes to all nodes
sleep 1; ssh cabeee@192.168.20.144 'nfdc route add /interCACHE udp://192.168.20.147 >/dev/null 2>&1 &'
#sleep 1; ssh cabeee@192.168.20.147 'nfdc route add /interCACHE udp://192.168.20.147 >/dev/null 2>&1 &'

#sleep 1; ssh cabeee@192.168.20.144 'nfdc route add /interCACHE/sensor udp://192.168.20.147 >/dev/null 2>&1 &'
#sleep 1; ssh cabeee@192.168.20.144 'nfdc route add /interCACHE/service1 udp://192.168.20.147 >/dev/null 2>&1 &'
#sleep 1; ssh cabeee@192.168.20.144 'nfdc route add /interCACHE/service2 udp://192.168.20.147 >/dev/null 2>&1 &'
#sleep 1; ssh cabeee@192.168.20.144 'nfdc route add /interCACHE/service3 udp://192.168.20.147 >/dev/null 2>&1 &'
#sleep 1; ssh cabeee@192.168.20.144 'nfdc route add /interCACHE/service4 udp://192.168.20.147 >/dev/null 2>&1 &'
#sleep 1; ssh cabeee@192.168.20.147 'nfdc route add /interCACHE/sensor udp://192.168.20.147 >/dev/null 2>&1 &'
#sleep 1; ssh cabeee@192.168.20.147 'nfdc route add /interCACHE/service1 udp://192.168.20.147 >/dev/null 2>&1 &'
#sleep 1; ssh cabeee@192.168.20.147 'nfdc route add /interCACHE/service2 udp://192.168.20.147 >/dev/null 2>&1 &'
#sleep 1; ssh cabeee@192.168.20.147 'nfdc route add /interCACHE/service3 udp://192.168.20.147 >/dev/null 2>&1 &'
#sleep 1; ssh cabeee@192.168.20.147 'nfdc route add /interCACHE/service4 udp://192.168.20.147 >/dev/null 2>&1 &'

#sleep 1; ssh cabeee@192.168.20.144 'nfdc route add /interCACHE/sensor udp://192.168.20.151 >/dev/null 2>&1 &'
#sleep 1; ssh cabeee@192.168.20.144 'nfdc route add /interCACHE/service1 udp://192.168.20.147 >/dev/null 2>&1 &'
#sleep 1; ssh cabeee@192.168.20.144 'nfdc route add /interCACHE/service2 udp://192.168.20.151 >/dev/null 2>&1 &'
#sleep 1; ssh cabeee@192.168.20.144 'nfdc route add /interCACHE/service3 udp://192.168.20.147 >/dev/null 2>&1 &'
#sleep 1; ssh cabeee@192.168.20.144 'nfdc route add /interCACHE/service4 udp://192.168.20.147 >/dev/null 2>&1 &'

#sleep 1; ssh cabeee@192.168.20.147 'nfdc route add /interCACHE/sensor udp://192.168.20.151 >/dev/null 2>&1 &'
#sleep 1; ssh cabeee@192.168.20.147 'nfdc route add /interCACHE/service1 udp://192.168.20.147 >/dev/null 2>&1 &'
#sleep 1; ssh cabeee@192.168.20.147 'nfdc route add /interCACHE/service2 udp://192.168.20.151 >/dev/null 2>&1 &'
#sleep 1; ssh cabeee@192.168.20.147 'nfdc route add /interCACHE/service3 udp://192.168.20.147 >/dev/null 2>&1 &'
#sleep 1; ssh cabeee@192.168.20.147 'nfdc route add /interCACHE/service4 udp://192.168.20.147 >/dev/null 2>&1 &'

#sleep 1; ssh cabeee@192.168.20.151 'nfdc route add /interCACHE/sensor udp://192.168.20.151 >/dev/null 2>&1 &'
#sleep 1; ssh cabeee@192.168.20.151 'nfdc route add /interCACHE/service1 udp://192.168.20.147 >/dev/null 2>&1 &'
#sleep 1; ssh cabeee@192.168.20.151 'nfdc route add /interCACHE/service2 udp://192.168.20.151 >/dev/null 2>&1 &'
#sleep 1; ssh cabeee@192.168.20.151 'nfdc route add /interCACHE/service3 udp://192.168.20.147 >/dev/null 2>&1 &'
#sleep 1; ssh cabeee@192.168.20.151 'nfdc route add /interCACHE/service4 udp://192.168.20.147 >/dev/null 2>&1 &'

sleep 1; ssh cabeee@192.168.20.147 'nfdc route add /interCACHE udp://192.168.20.147 >/dev/null 2>&1 &'
sleep 1; ssh cabeee@192.168.20.147 'nfdc route add /interCACHE/sensor udp://192.168.20.151 >/dev/null 2>&1 &'
sleep 1; ssh cabeee@192.168.20.147 'nfdc route add /interCACHE/service2 udp://192.168.20.151 >/dev/null 2>&1 &'
sleep 1; ssh cabeee@192.168.20.147 'nfdc route add /interCACHE/service4 udp://192.168.20.151 >/dev/null 2>&1 &'

sleep 1; ssh cabeee@192.168.20.151 'nfdc route add /interCACHE udp://192.168.20.151 >/dev/null 2>&1 &'
sleep 1; ssh cabeee@192.168.20.151 'nfdc route add /interCACHE/sensor udp://192.168.20.145 >/dev/null 2>&1 &'
sleep 1; ssh cabeee@192.168.20.151 'nfdc route add /interCACHE/service1 udp://192.168.20.147 >/dev/null 2>&1 &'
sleep 1; ssh cabeee@192.168.20.151 'nfdc route add /interCACHE/service3 udp://192.168.20.147 >/dev/null 2>&1 &'

sleep 1; ssh cabeee@192.168.20.145 'nfdc route add /interCACHE udp://192.168.20.145 >/dev/null 2>&1 &'
sleep 1; ssh cabeee@192.168.20.145 'nfdc route add /interCACHE/service1 udp://192.168.20.151 >/dev/null 2>&1 &'
sleep 1; ssh cabeee@192.168.20.145 'nfdc route add /interCACHE/service2 udp://192.168.20.151 >/dev/null 2>&1 &'
sleep 1; ssh cabeee@192.168.20.145 'nfdc route add /interCACHE/service3 udp://192.168.20.151 >/dev/null 2>&1 &'
sleep 1; ssh cabeee@192.168.20.145 'nfdc route add /interCACHE/service4 udp://192.168.20.151 >/dev/null 2>&1 &'

# 4 DAG - Orchestrator A
# start producer application
#sleep 1; ssh cabeee@192.168.20.151 '~/ndn/ndn-cxx/build/examples/cabeee-custom-app-producer /interCACHE /sensor >/dev/null 2>&1 &'
# start orchestratorA application
#sleep 1; ssh cabeee@192.168.20.151 '~/ndn/ndn-cxx/build/examples/cabeee-dag-orchestratorA-app /interCACHE /serviceOrchestration >/dev/null 2>&1 &'
# start forwarder application(s)
#sleep 1; ssh cabeee@192.168.20.151 '~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceA-app /interCACHE /service1 >/dev/null 2>&1 &'
#sleep 1; ssh cabeee@192.168.20.151 '~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceA-app /interCACHE /service2 >/dev/null 2>&1 &'
#sleep 1; ssh cabeee@192.168.20.151 '~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceA-app /interCACHE /service3 >/dev/null 2>&1 &'
#sleep 1; ssh cabeee@192.168.20.151 '~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceA-app /interCACHE /service4 >/dev/null 2>&1 &'
# start consumer application (locally so that we see the final print statements)
#sleep 1; ~/mini-ndn/dl/ndn-cxx/build/examples/cabeee-custom-app-consumer /interCACHE ~/mini-ndn/workflows/4dag.json 1


# 4 DAG - Orchestrator B
# start producer application
#sleep 1; ssh cabeee@192.168.20.151 '~/ndn/ndn-cxx/build/examples/cabeee-custom-app-producer /interCACHE /sensor >/dev/null 2>&1 &'
# start orchestratorA application
#sleep 1; ssh cabeee@192.168.20.151 '~/ndn/ndn-cxx/build/examples/cabeee-dag-orchestratorB-app /interCACHE /serviceOrchestration >/dev/null 2>&1 &'
# start forwarder application(s)
#sleep 1; ssh cabeee@192.168.20.151 '~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceB-app /interCACHE /service1 >/dev/null 2>&1 &'
#sleep 1; ssh cabeee@192.168.20.151 '~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceB-app /interCACHE /service2 >/dev/null 2>&1 &'
#sleep 1; ssh cabeee@192.168.20.151 '~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceB-app /interCACHE /service3 >/dev/null 2>&1 &'
#sleep 1; ssh cabeee@192.168.20.151 '~/ndn/ndn-cxx/build/examples/cabeee-dag-serviceB-app /interCACHE /service4 >/dev/null 2>&1 &'
# start consumer application (locally so that we see the final print statements)
#sleep 1; ~/mini-ndn/dl/ndn-cxx/build/examples/cabeee-custom-app-consumer /interCACHE ~/mini-ndn/workflows/4dag.json 2



# 4 DAG - interCACHE Forwarder
# start producer application
#sleep 1; ssh cabeee@192.168.20.147 '~/ndn/ndn-cxx/build/examples/cabeee-custom-app-producer /interCACHE /sensor >/dev/null 2>&1 &'
# start forwarder application(s)
#sleep 1; ssh cabeee@192.168.20.147 '~/ndn/ndn-cxx/build/examples/cabeee-dag-forwarder-app /interCACHE /service1 >/dev/null 2>&1 &'
#sleep 1; ssh cabeee@192.168.20.147 '~/ndn/ndn-cxx/build/examples/cabeee-dag-forwarder-app /interCACHE /service2 >/dev/null 2>&1 &'
#sleep 1; ssh cabeee@192.168.20.147 '~/ndn/ndn-cxx/build/examples/cabeee-dag-forwarder-app /interCACHE /service3 >/dev/null 2>&1 &'
#sleep 1; ssh cabeee@192.168.20.147 '~/ndn/ndn-cxx/build/examples/cabeee-dag-forwarder-app /interCACHE /service4 >/dev/null 2>&1 &'
# start consumer application (locally so that we see the final print statements)
#sleep 1; ~/mini-ndn/dl/ndn-cxx/build/examples/cabeee-custom-app-consumer /interCACHE ~/mini-ndn/workflows/4dag.json 0

# 4 DAG - interCACHE Forwarder
# start producer application
sleep 1; ssh cabeee@192.168.20.145 '~/ndn/ndn-cxx/build/examples/cabeee-custom-app-producer /interCACHE /sensor >/dev/null 2>&1 &'
# start forwarder application(s)
sleep 1; ssh cabeee@192.168.20.147 '~/ndn/ndn-cxx/build/examples/cabeee-dag-forwarder-app /interCACHE /service1 >/dev/null 2>&1 &'
sleep 1; ssh cabeee@192.168.20.151 '~/ndn/ndn-cxx/build/examples/cabeee-dag-forwarder-app /interCACHE /service2 >/dev/null 2>&1 &'
sleep 1; ssh cabeee@192.168.20.147 '~/ndn/ndn-cxx/build/examples/cabeee-dag-forwarder-app /interCACHE /service3 >/dev/null 2>&1 &'
sleep 1; ssh cabeee@192.168.20.151 '~/ndn/ndn-cxx/build/examples/cabeee-dag-forwarder-app /interCACHE /service4 >/dev/null 2>&1 &'
# start consumer application (locally so that we see the final print statements)
sleep 1; ~/mini-ndn/dl/ndn-cxx/build/examples/cabeee-custom-app-consumer /interCACHE ~/mini-ndn/workflows/4dag.json 0





# 20 Linear


# 20 Parallel


# 20 Sensor (Parallel)


# 8 DAG


# 8 DAG w/ caching







