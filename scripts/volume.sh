#!/bin/bash

# Changes the default PulseAudio sink volume and plays a feedback sound (the freedesktop "bell").
# If the sound file is missing, install the sound-theme-freedesktop package (Arch; "sound-theme-freedesktop" on
# Debian/Ubuntu too). The sound is by Dr. Richard Boulanger et al, CC-BY 3.0 (https://archive.org/details/Berklee44v12).
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

paplay /usr/share/sounds/freedesktop/stereo/bell.oga
#notify-send -t 1000 -u normal "Volume: 123" -a volume -r 88866655588699
