#!/bin/bash

[ $# -lt 2 ] && {
	echo "$0 <iface name> <bridge name>"
	exit 1
}

iface=$1
bridge=$2

grep -q ${iface} /proc/net/dev || {
	echo "iface ${iface} not exist"
	exit 1
}

grep -q "\<${bridge}\>" /proc/net/dev || {
	virsh iface-bridge ${iface} ${bridge} --no-stp
	systemctl restart network
}

# delete bridge
# virsh iface-unbridge br0
