#!/bin/bash

# Daemon: every 5 minutes checks /home usage and sends a critical desktop
# notification once when free space drops to 1% or less (re-arms when it recovers).
# Usage: ./freespace.sh &   (needs df, notify-send)

declare -i lowSpace
lowSpace=0
while [ true ]
do
	declare -i freeSpace=$(df | grep /home | awk '{print $5}' | tr -d %)
		if [  $[ 100 - $freeSpace ] -le 1 -a $lowSpace -eq 0 ]
		then
			notify-send -u critical "/home free capacity is less than $[ 100 - $freeSpace ]%"
			lowSpace=1
		fi
		if [ $[ 100 - $freeSpace ] -gt 1 -a $lowSpace -eq 1 ]
		then
			lowSpace=0
		fi
	sleep 300
done
