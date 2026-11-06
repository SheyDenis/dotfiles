#!/bin/bash

# Mutes the default ALSA card: sets every "Playback Volume" control to 0% and every "Playback Switch" control off.
# Capture and other controls are left untouched.
# Usage: ./mute.sh   (needs amixer)

echo "$(date) - Starting $0"

sleep 1s

while IFS= read -r control; do
	numid="$(grep -o 'numid=[0-9]\+' <<< "${control}" | grep -o '[0-9]\+')"
	case "${control}" in
	*"Playback Volume'") amixer cset numid="${numid}" 0% ;;
	*"Playback Switch'") amixer cset numid="${numid}" off ;;
	esac
done < <(amixer controls)

echo "Done $0"
