#!/bin/sh

# Enables only DisplayPort-1 as primary at 3440x1440 (21:9) and turns off the other outputs.
# Usage: ./only_primary_21_9.sh   (needs xrandr; output names are hardcoded)
xrandr --output DisplayPort-1 --primary --mode 3440x1440 --pos 0x0 --rotate normal --output DisplayPort-0 --off --output DisplayPort-2 --off --output HDMI-A-0 --off
