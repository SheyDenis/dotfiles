#!/bin/bash

# Prints the headset battery level (e.g. "80%") via headsetcontrol, or "-100%" if unavailable.
# Usage: ./headphonesbattery.sh   (meant for status bars; needs headsetcontrol)

level="$(headsetcontrol -b 2> /dev/null | tail -1 | cut -d" " -f2)"
if [ ${#level} -gt 1 ]; then
	echo ${level}
else
	echo "-100%"
fi
