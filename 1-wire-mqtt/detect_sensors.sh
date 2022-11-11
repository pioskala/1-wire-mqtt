#!/bin/bash
source "/root/include.sh"

in=$(digitemp_DS9097U -s /dev/ttyUSB0 -i -q)


IFS=$'\n' read -d '' -ra array < <(printf '%s;\0' "$in")




for i in "${array[@]}"
do
   if [[ $i == *":"* ]]; then # if we have sensor id - 64 bit starting with '28h'
      IFS=':' read -ra sensorid < <(printf '%s;\0' "$i")
	  #echo "$sensorid"
	  tsensorid=${sensorid// } #trim!!!
	  #echo "$tsensorid"
	  if [ ${#tsensorid} = 16 ] && [[ $tsensorid == "28"* ]]; then # if we have sensor id - 64 bit starting with '28h'
	     #echo "$tsensorid"
		 mosquitto_pub -r -h $mqtthost -u $mqttuser -P $mqttpass -t "homeassistant/sensor/1-wire/${tsensorid}/config" -m "{\"name\": \"1-wire_${sensnames[${sensorid}]}\", \"device_class\": \"temperature\", \"state_topic\": \"homeassistant/sensor/1-wire/${tsensorid}/state\", \"unit_of_measurement\": \"°C\", \"value_template\": \"{{ value_json.temperature}}\" }"
	  fi
   fi
   # do whatever on "$i" here
done

