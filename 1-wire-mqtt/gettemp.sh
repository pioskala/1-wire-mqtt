#!/bin/bash
source "/root/include.sh"

temp=( $(digitemp_DS9097U -s /dev/ttyUSB0 -q -a -o "%R %.2C") )


sensorid=""
seconds=$(date +%s)





for i in "${temp[@]}"
do
   if [ ${#i} = 16 ] && [[ $i == "28"* ]]; then # if we have sensor id - 64 bit starting with '28h'
      sensorid=$i
   elif [ ! -z "$sensorid" ]; then
      # echo $i
      #mosquitto_pub -h 192.168.10.95 -u 'piotr' -P 'piotr' -m "{\"temperature\" : $i, \"unixtime\" : \"${seconds}\"}" -t "homeassistant/sensor/1-wire/${sensorid}/state"
	  mosquitto_pub -h $mqtthost -u $mqttuser -P $mqttpass -m "{\"temperature\" : $i}" -t "homeassistant/sensor/1-wire/${sensorid}/state"
      sensorid=""
   else
      # echo $sensorid
      sensorid=""
   fi
   # do whatever on "$i" here
done