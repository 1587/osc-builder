#!/bin/bash
WORKDIR=/home
FILE=/data/diskimage_${1}.qcow2
KERNEL=$2
ROOTFS=$3
#运行docker容器的host 网桥docker0的ip
DOCKER0_IP=`/sbin/ip route|awk '/default/ { print $3 }'`
echo "DOCKER0_IP=${DOCKER0_IP}"
#docker 容器内部的ip
DOCKER_CONTAINER_IP=`/sbin/ifconfig -a|grep inet|grep -v 127.0.0.1|grep -v inet6|awk '{print $2}'|tr -d "addr:"`
echo "DOCKER_CONTAINER_IP=${DOCKER_CONTAINER_IP}"
if [ X"$4" == "X" ];then
    INIT=/sbin/init
else
    INIT=$4
fi
if [ "$1" == "powerpc" ]; then
    ARCH=powerpc
    QEMU_SYSTEM_BIN=qemu-system-ppc
    QEMU_OPTION_CPU=" -m 1024 -M mac99 -cpu G4 "
    QEMU_OPTION_NET=" -net nic,macaddr=52:54:00:12:34:56,model=pcnet -net tap,ifname=tap0,script=no,downscript=no "
    QEMU_OPTION_APPEND="root=/dev/hda1 init=${INIT} console=ttyS0,115200 rw -"
    #QEMU_OPTION_APPEND="root=/dev/ram rdinit=${INIT} console=ttyS0,115200 ip=dhcp rw TCF=1 -"
    if [ X"$2" == "X" ];then
        KERNEL=/home/powerpc-qemu/image
    fi
    if [ X"$3" == "X" ];then
        ROOTFS=/home/powerpc-qemu/rootfs.cpio.gz
    fi
elif [ "$1" == "armel" ]; then
    ARCH=armel
    QEMU_SYSTEM_BIN=qemu-system-arm
    QEMU_OPTION_CPU=" -m 256 -M versatilepb "
    QEMU_OPTION_NET=" -net nic,macaddr=52:54:00:12:34:56 -net tap,ifname=tap0,script=no,downscript=no "
    QEMU_OPTION_APPEND="root=/dev/sda1 init=${INIT} console=ttyAMA0,115200 rw UMA=1"
    if [ X"$2" == "X" ];then
        KERNEL=/home/armel-qemu/image
    fi
    if [ X"$3" == "X" ];then
        ROOTFS=/home/armel-qemu/rootfs.cpio.gz
    fi
elif [ "$1" == "x86_64" ]; then
    ARCH=x86_64
    QEMU_SYSTEM_BIN=qemu-system-x86_64
    QEMU_OPTION_CPU="-m 2048 -cpu core2duo "
    QEMU_OPTION_NET=" -net user,hostname=qemu0 -net nic,macaddr=52:54:00:12:34:56,model=i82557b -net tap,ifname=tap0,script=no,downscript=no  -show-cursor -usb -usbdevice wacom-tablet -vga vmware "
    QEMU_OPTION_APPEND="root=/dev/sda1 init=${INIT} console=ttyS0,115200 noapic rw clocksource=pit oprofile.timer=1 TCF=1"
    #QEMU_OPTION_APPEND="root=/dev/ram rdinit=${INIT} console=ttyS0,115200 rw clocksource=pit oprofile.timer=1 TCF=1"
    if [ X"$2" == "X" ];then
        KERNEL=/home/x86_64-qemu/image
    fi
    if [ X"$3" == "X" ];then
        ROOTFS=/home/x86_64-qemu/rootfs.cpio.gz
    fi
elif [ "$1" == "arm64" ]; then
    ARCH=aarch64
    QEMU_SYSTEM_BIN=qemu-system-aarch64
    QEMU_OPTION_CPU=" -m 1024 -M virt -cpu cortex-a57 "
    QEMU_OPTION_NET=" -net tap,ifname=tap0,script=no,downscript=no  -device virtio-net-device,vlan=0 -drive file=${FILE},if=none,id=blk -device virtio-blk-device,drive=blk" \
    QEMU_OPTION_APPEND="root=/dev/vda1 init=${INIT} console=ttyAMA0 rw noapic"
    #QEMU_OPTION_APPEND="root=/dev/ram rdinit=${INIT} console=ttyAMA0 rw noapic"
    if [ X"$2" == "X" ];then
        KERNEL=/home/aarch64-qemu/image
    fi
    if [ X"$3" == "X" ];then
        ROOTFS=/home/aarch64-qemu/rootfs.cpio.gz
    fi
else
    echo "usage:"
    echo "       ./start_qemu.sh {powerpc|armel|arm64|x86_64} [{kernel-path}  {rootfs-path}]"
    echo " "
    exit 1
fi
   echo "ARCH:            ${ARCH}"
   echo "CPU:             ${CPU}"
   echo "QEMU_SYSTEM_BIN: ${QEMU_SYSTEM_BIN}"
   echo "KERNEL:          ${KERNEL}"
   echo "ROOTFS:          ${ROOTFS}"

#create qemu disk
sudo modprobe nbd max_part=16
if [ -e ${FILE} ];then
  echo "${FILE} is already exits,we will use ${FILE}"
else
    sudo qemu-img create -f qcow2 ${FILE} 10G
    for i in /dev/nbd*
    do
    	if sudo qemu-nbd -c $i $FILE
    	then
    		DISK=$i
    		break
    	fi
    done
    sudo sfdisk ${DISK} -q -uM << EOF
;;L
EOF
    sudo mkfs.ext4 -q ${DISK}p1
    sudo mkdir ${WORKDIR}/tmp_rootfs
    sudo mount ${DISK}p1 ${WORKDIR}/tmp_rootfs
    sudo cp ${ROOTFS} ${WORKDIR}/tmp_rootfs/rootfs.cpio.gz
    cd ${WORKDIR}/tmp_rootfs/
    sudo gunzip rootfs.cpio.gz
    sudo cpio -idm < rootfs.cpio
    sudo rm rootfs.cpio
    cd ${WORKDIR}
    sudo umount ${DISK}p1
    sudo qemu-nbd -d /dev/nbd0
    sudo rm -rf ${WORKDIR}/tmp_rootfs
fi
echo "sudo ${QEMU_SYSTEM_BIN} -nographic -k en-us \
     -hda ${FILE}  \
     -kernel ${KERNEL} \
     ${QEMU_OPTION_CPU} ${QEMU_OPTION_NET} \
     -append \"bridgeip=${DOCKER_CONTAINER_IP} ${QEMU_OPTION_APPEND}\" "

#新建网桥br0
sudo brctl addbr br0
#把eth0加入br0
sudo brctl addif br0 eth0
#给网桥配置ip，要和host的网桥docker0在一个网段
sudo ifconfig br0  ${DOCKER_CONTAINER_IP} netmask 255.255.0.0
#把eth0的ip去掉
sudo ifconfig eth0 0.0.0.0 promisc up
#添加eth0的默认网关，应该是host上的docker0网桥的ip 默认是172.17.42.1
sudo route add default gw ${DOCKER0_IP} br0
#新建tap0
sudo tunctl -t tap0 -u root
sudo brctl addif br0 tap0
sudo ifconfig tap0 0.0.0.0 promisc up
echo "show qemu br0 info"
sudo brctl showstp br0
route
sudo ${QEMU_SYSTEM_BIN} -nographic -k en-us \
     -hda ${FILE}  \
     -kernel ${KERNEL} \
     ${QEMU_OPTION_CPU} ${QEMU_OPTION_NET} \
     -append "bridgeip=${DOCKER_CONTAINER_IP} ${QEMU_OPTION_APPEND}"
echo "DOCKER0_IP=${DOCKER0_IP}"
#添加eth0的默认网关，应该是host上的docker0网桥的ip 默认是172.17.42.1
sudo route add default gw ${DOCKER0_IP} br0
echo "if necessary,please sudo rm -rf ${FILE}"
#-initrd ${ROOTFS} 
