#!/bin/bash

virt-install \
	--name {{ vm_name }} \
	--os-type linux \
	--os-variant "{{ os_variant }}" \
	--memory {{ memory_mb }} \
	--vcpus {{ vcpus }} \
	--disk path={{ vdisk_path }}/disk.img,bus=virtio,size={{ vdisk_size }} \
	--network bridge={{ bridge }} \
	--graphics vnc,listen=0.0.0.0,keymap=en-us \
	--location {{ iso_path }} \
	--extra-args console=ttyS0
