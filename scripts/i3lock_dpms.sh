#!/bin/bash

# Locks the screen with i3lock: mutes audio, turns the display off after 20s while locked,
# and restores the normal 1200s DPMS timeout on unlock or on HUP/INT/TERM.
# Usage: ./i3lock_dpms.sh   (needs i3lock, xset; calls mute.sh from the same directory)

revert() {
  xset dpms 0 0 1200
}
$(dirname $0)/mute.sh &
trap revert HUP INT TERM
xset +dpms dpms 0 0 20
i3lock -n
revert
