#!/bin/bash

name=${1:-{{ vm_name }}}
mkdir -p {{ kvm_path }}/${name}

virt-install \
	--name ${name} \
	--os-type linux \
	--os-variant "{{ os_variant }}" \
	--memory {{ memory_mb }} \
	--vcpus {{ vcpus }},cpuset={{ cpuset }} \
    --numatune nodeset={{ nodeset }} \
	--disk path={{ kvm_path }}/${name}/disk.img,bus=virtio,size={{ vdisk_size }} \
	--network bridge={{ bridge }} \
	--graphics vnc,listen=0.0.0.0,keymap=en-us \
	--location {{ iso_path }} \
	--extra-args console=ttyS0
