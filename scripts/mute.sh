#!/bin/bash

# Sets every ALSA control (amixer controls) to 0% and off, i.e. mutes all audio.
# Usage: ./mute.sh   (needs amixer)

echo "$(date) - Starting $0"

OIFS=$IFS
IFS=$'\n'
sleep 1s

for control in $(amixer controls); do
	numid="$(echo $control | grep -o 'numid=[0-9]\+' | grep -o '[0-9]\+')"
	amixer cset numid=${numid} 0% off
done

IFS=$OIFS
echo "Done $0"
