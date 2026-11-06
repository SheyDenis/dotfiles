#!/bin/bash

# Prints this month's bandwidth usage as reported by vnstat.
# Usage: ./monthlybandwidth.sh [-m] [-h]   (-m prefixes the month name, -h prints help; needs vnstat)

# Field 11 of the --oneline output is the current month's total (vnstat 2.x), e.g. "100.07 GiB".
BANDWIDTH_USAGE="$(vnstat -m --oneline | cut -d';' -f11 | tr -d ' ')"
OUTPUT_STR="${BANDWIDTH_USAGE}"

print_help() {
	cat <<EOF
Usage:
  No parameters : Outputs this month's bandwidth usage with postfix depending on vnstat.
  -m : The same as no parameters but prefix the output of "date +%b" to the output.
  -h : Prints this help and exits.
EOF
}

while [[ $# -gt 0 ]]; do
	key="$1"

	case $key in
		-m)
			OUTPUT_STR="$(date +%b): $OUTPUT_STR"
			shift
			;;
		-h)
			print_help
			exit 0
			;;
		*)
			print_help
			exit 1
			;;
	esac
done

echo "${OUTPUT_STR}"
