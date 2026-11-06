#!/bin/bash

# Changes the default PulseAudio sink volume and plays a feedback sound (~/.sounds/drip.ogg).
# Usage: ./volume.sh +   (unmute, volume +5%)
#        ./volume.sh -   (volume -5%)
#        ./volume.sh m   (toggle mute)
# Needs pactl, paplay.

case "$1" in
  +)
  pactl set-sink-mute @DEFAULT_SINK@ off
  pactl set-sink-volume @DEFAULT_SINK@ +5%
  ;;
  -)
  pactl set-sink-volume @DEFAULT_SINK@ -5%
  ;;
  m)
  pactl set-sink-mute @DEFAULT_SINK@ toggle
  ;;
esac

paplay ${HOME}/.sounds/drip.ogg
#notify-send -t 1000 -u normal "Volume: 123" -a volume -r 88866655588699
