#!/bin/bash

# Prints this month's bandwidth usage as reported by vnstat.
# Usage: ./monthlybandwidth.sh [-m] [-h]   (-m prefixes the month name, -h prints help; needs vnstat)
#echo $(vnstat -m | grep $(date +%b) | tail -1 |awk '{print $9$10}')

BANDWIDTH_USAGE=$(vnstat -m | tail -3 | head -1 |awk '{print $8$9}')
OUTPUT_STR=$BANDWIDTH_USAGE

function print_help(){
	HELP="Usage:\n
		No parameters : Outputs this month's bandwidth usage with postfix depending on vnstat.\n
		-m : The same as no parameters but prefix the output of \"date +%b\" to the output.\n
		-h : Prints this help and exits.\n "
	echo -e $HELP
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

echo $OUTPUT_STR
