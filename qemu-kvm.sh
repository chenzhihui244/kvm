#!/bin/sh

host_iface=enp125s0f0
ovs_bridge=ovsbr0
bridge=br0
vmname=ovsvm3
#vmname=euleros2.8
vm_root=/vm/images
os_variant=centos7.0
memory_mb=16384

vcpus=8
cpuset="24-31"
nodeset=1

vdisk_size="120"
iso_path=/c00365621/CentOS-7-aarch64-Everything-1810.iso
#iso_path=/c00365621/EulerOS-V2.0SP8-aarch64-dvd.iso

err() {
	printf "\e[31m"
	printf "$1"
	printf "\e[0m"
	printf "\n"
	return
}

die() {
	printf "\e[31m"
	printf "$1"
	printf "\e[0m"
	printf "\n"
	exit -1
}

prepare() {
	echo "install dependencies..."
	yum install -q -y AAVMF qemu-kvm libvirt virt-install
	echo "start libvirtd..."
	systemctl start libvirtd
}

setup_bridge() {
	echo "setup bridge..."
	grep -q ${host_iface} /proc/net/dev || {
		die "${host_iface} not exist"
	}
	grep -q ${bridge} /proc/net/dev || {
		virsh iface-bridge ${host_iface} ${bridge} --no-stp
		systemctl restart network
	}
}

create_vm_ovsnet() {
	local vmname=$1

	virsh list --all | grep $vmname && {
		echo "${vmname} exist"
		return
	}
	[ -d ${vm_root} ] || die "${vm_root} not present"
	mkdir -p ${vm_root}/${vmname}
	echo "create vm ${vmname}"

	set -x
	virt-install \
	--name ${vmname} \
	--os-type linux \
	--os-variant "${os_variant}" \
	--memory ${memory_mb} \
	--vcpus ${vcpus},cpuset=${cpuset} \
	--numatune nodeset=${nodeset} \
	--network type=direct,source=${ovs_bridge} \
	--disk path=${vm_root}/${vmname}/disk.img,bus=virtio,size=${vdisk_size} \
	--graphics vnc,listen=0.0.0.0,keymap=en-us \
	--location ${iso_path} \
	--extra-args console=ttyS0
	set +x
}

create_vm() {
	local vmname=$1

	virsh list | grep $vmname && {
		echo "${vmname} exist"
		return
	}
	[ -d ${vm_root} ] || die "${vm_root} not present"
	mkdir -p ${vm_root}/${vmname}
	echo "create vm ${vmname}"

set -x

	virt-install \
	--name ${vmname} \
	--os-type linux \
	--os-variant "${os_variant}" \
	--memory ${memory_mb} \
	--vcpus ${vcpus},cpuset=${cpuset} \
	--numatune nodeset=${nodeset} \
	--disk path=${vm_root}/${vmname}/disk.img,bus=virtio,size=${vdisk_size} \
	--network bridge=${bridge} \
	--graphics vnc,listen=0.0.0.0,keymap=en-us \
	--location ${iso_path} \
	--extra-args console=ttyS0
set +x
}

clone_vm() {
	[ $# -lt 2 ] && {
		echo "usage: <oldname> <newname>"
		return
	}
	local oname=$1
	local nname=$2
	virsh list --all | grep -q ${oname} || {
		err "vm ${oname} not exist"
		return
	}
	virsh list --all | grep -q ${nname} && {
		err "vm ${nname} exist"
		return
	}
	mkdir -p ${vm_root}/${nname}
	virt-clone -o ${oname} -n ${nname} -f ${vm_root}/${nname}/disk.img
}

delete_vm() {
	[ -z $1 ] && {
		err "usage: delete_vm <vm_name>"
		return
	}
	local name=$1
	virsh list --all | grep -q ${name} || {
		err "vm ${name} not exist"
		return
	}
	virsh undefine --nvram ${name}
}

#prepare
#setup_bridge
#create_vm ${vmname}
create_vm_ovsnet ${vmname}
#clone_vm ovsvm1 ovsvm2
