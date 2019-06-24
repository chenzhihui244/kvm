#!/bin/bash

name=${1:-{{ vm_name }}}
mkdir -p {{ kvm_path }}/${name}

virt-install \
	--name {{ vm_name }}-ks \
	--os-type linux \
	--os-variant "{{ os_variant }}" \
	--memory {{ memory_mb }} \
	--vcpus {{ vcpus }},cpuset={{ cpuset }} \
    --numatune nodeset={{ nodeset }} \
	--disk path={{ kvm_path }}/disk.img,bus=virtio,size=32 \
	--network bridge={{ bridge }} \
	--graphics vnc,listen=0.0.0.0,keymap=en-us \
	--location {{ url_path }} \
	--extra-args="ks={{ ks_path }}" \
	--extra-args console=ttyS0
