#!/bin/bash

# Locks the screen with mate-screensaver, then turns the display off after 5 seconds.
# Usage: ./lock_blank.sh   (needs mate-screensaver-command, xset)

mate-screensaver-command --lock
sleep 5
xset dpms force off
