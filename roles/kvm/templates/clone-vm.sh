#!/bin/bash

[ -z $1 ] && {
	echo "usage: $0 <new vm>"
	exit 1
}

new_vm=$1

mkdir -p {{ kvm_path }}/${new_vm}
virt-clone -o {{ vm_name }} -n ${new_vm} -f {{ kvm_path }}/${new_vm}/disk.img
