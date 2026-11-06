#!/bin/sh

# Keeps only the currently active output, as primary, at the chosen resolution, and turns all other outputs off.
# Usage: ./only_primary.sh [32-9|21-9]   (default 32-9 = 5120x1440, 21-9 = 3440x1440; needs xrandr)

# Modes
MODE_32_9='32-9'
MODE_21_9='21-9'

MODE="${1:-${MODE_32_9}}"

echo "Selected mode: ${MODE}"

case "${MODE}" in
"${MODE_32_9}" | "${MODE_21_9}")
;;
*)
echo "Usage: ${0} [${MODE_32_9},${MODE_21_9}]"
exit 1
;;
esac

# xrandr modes
XRANDR_MODE_32_9='5120x1440'
XRANDR_MODE_21_9='3440x1440'

XRANDR_MODE=''

case "${MODE}" in
"${MODE_32_9}" )
XRANDR_MODE="${XRANDR_MODE_32_9}"
;;
 "${MODE_21_9}")
XRANDR_MODE="${XRANDR_MODE_21_9}"
;;
esac

echo "XRANDR_MODE: ${XRANDR_MODE}"

ACTIVE_OUTPUT="$(xrandr --listmonitors | tail -1 | grep -Eo '[a-zA-Z]+-[[:digit:]]+$')"

echo "ACTIVE_OUTPUT: ${ACTIVE_OUTPUT}"

declare -a XRANDR_OUTPUTS

for output in $(xrandr --current | tail -n +2 | grep -Eo '^[a-zA-Z]+-[^[:space:]]+'); do
  if [[ "${output}" == "${ACTIVE_OUTPUT}" ]]; then
    XRANDR_OUTPUTS=(${XRANDR_OUTPUTS[@]} "--output ${ACTIVE_OUTPUT} --primary --mode ${XRANDR_MODE} --pos 0x0 --rotate normal")
  else
    XRANDR_OUTPUTS=(${XRANDR_OUTPUTS[@]} "--output ${output} --off")
  fi
done

echo "XRANDR_OUTPUTS: ${XRANDR_OUTPUTS[*]}"
xrandr ${XRANDR_OUTPUTS[*]}
