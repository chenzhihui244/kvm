#!/bin/bash

vm_name=${1:-{{ vm_name }}}
numa_node=${2:-0}
cpu_start=${3:-0}

systemctl start tuned
tuned-adm profile virtual-host
# command in vm
# tuned-adm profile virtual-guest

virsh numatune ${vm_name} --mode strict --nodeset ${numa_node} --live --config

i=0
while (( i < {{ vcpus }} )); do
	let rcpu=cpu_start+i
	virsh vcpupin ${vm_name} --vcpu $i --cpulist ${rcpu} --live --config
	let i++
done
