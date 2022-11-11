#!/bin/bash
source "/root/include.sh"


sensors=false





input="/root/.digitemprc"
while IFS= read -r line
do
   if [ "$sensors" = true ]; then
	 sensorid=""
	 IFS=$' ' read -d '' -ra array < <(printf '%s;\0' "$line")

	 if (( "${#array[@]}" >= 10 )); then
	   for i in "${array[@]}"
	   do
	     if (( "${#i}" == 4 )); then
		   if [[ "${i:0:2}" == "0x" ]]; then
		     #echo "${i:2:2}"
		     sensorid="${sensorid}${i:2:2}"
		   fi
	        
	     fi
	   done
	   
	   if [ ${#sensorid} = 16 ] && [[ $sensorid == "28"* ]]; then # if we have sensor id - 64 bit starting with '28h'
	     mosquitto_pub -r -h $mqtthost -u $mqttuser -P $mqttpass -t "homeassistant/sensor/1-wire/${sensorid}/config" -m "{\"name\": \"1-wire_${sensnames[${sensorid}]}\", \"device_class\": \"temperature\", \"state_topic\": \"homeassistant/sensor/1-wire/${sensorid}/state\", \"unit_of_measurement\": \"°C\", \"value_template\": \"{{ value_json.temperature}}\" }"
	   fi
	   
	 fi
   else
	  if [[ $line == "SENSOR"* ]]; then
		 sensors=true
	  fi
   fi
done < "$input"