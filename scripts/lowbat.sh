#!/bin/bash

# Daemon: every 5 minutes, while the battery is discharging, logs its level to /dev/tty8
# and sends a critical desktop notification at 15% or below.
# Usage: ./lowbat.sh &   (needs acpi, notify-send)

while [ true ]
do
	if [ "$(acpi -b | awk '{print $3}')" == "Discharging," ]
		then
		declare -i per=$(acpi -b | awk '{print $4}' | tr -d %,)
		echo "Battery is at $per%." >> /dev/tty8
		if [ $per -le 15 ]
		then
			notify-send -u critical "Battery is at $per%."
		fi
	fi
	sleep 300
done
