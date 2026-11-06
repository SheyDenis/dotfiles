#!/bin/bash

# Mutes Master/Speaker audio, locks the session with dm-tool, waits 5s, then suspends the system.
# Logs to /tmp/suspendlock.log.
# Usage: ./suspendlock.sh   (needs amixer, dm-tool, systemctl)

# Log file for this script
LOG="/tmp/suspendlock.log"

echo "$(date) - Starting $0" >> $LOG

amixer set Master 0% on &>> $LOG
amixer set Master 0% on -c 0 &>> $LOG
amixer set Speaker 0% on &>> $LOG
amixer set Speaker 0% on -c 0 &>> $LOG

echo "$(date) - Locking screen" >> $LOG
dm-tool lock &>> $LOG
sleep 5
echo "$(date) - Suspending system" >> $LOG
systemctl suspend &>> $LOG
