# Prints "Connected" if 8.8.8.8 answers a ping within 1s, else "Not Connected".
# Usage: ./is_connected.sh

dest="8.8.8.8"

ping "${dest}" -c 1 -w 1 &> /dev/null && echo "Connected" || echo "Not Connected"
