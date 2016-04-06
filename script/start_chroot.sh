#!/bin/bash
WORKDIR=/home
   if [ "$1" == "powerpc" ]; then
       ROOTFS=${WORKDIR}/powerpc-chroot
       QEMU_PATH=${WORKDIR}/powerpc-qemu
   elif [ "$1" == "armel" ]; then
       ROOTFS=${WORKDIR}/armel-chroot
       QEMU_PATH=${WORKDIR}/armel-qemu
   elif [ "$1" == "x86_64" ]; then
       ROOTFS=${WORKDIR}/x86_64-chroot
       QEMU_PATH=${WORKDIR}/x86_64-qemu
   elif [ "$1" == "arm64" ]; then
       ROOTFS=${WORKDIR}/aarch64-chroot
       QEMU_PATH=${WORKDIR}/aarch64-qemu
   else
       echo "usage:"
       echo "       ./start_chroot.sh {powerpc|armel|arm64|x86_64}"
       echo " "
       exit 1
   fi
   echo "ROOTFS:${ROOTFS}"

if [ -e ${ROOTFS} ];then
  echo "${ROOTFS} is already exits,we will use ${ROOTFS}"
else
    sudo mkdir ${ROOTFS}
    cd ${ROOTFS}/
    sudo cp ${QEMU_PATH}/rootfs.cpio.gz ${ROOTFS}/rootfs.cpio.gz
    sudo gunzip ${ROOTFS}/rootfs.cpio.gz
    sudo cpio -idmV < rootfs.cpio
    sudo mkdir ${ROOTFS}/data
    sudo rm ${ROOTFS}/rootfs.cpio
fi
echo "mount ${ROOTFS}/data"
sudo mount -v -o bind /data ${ROOTFS}/data
cd ${WORKDIR}/
echo "root passwd is root"
sudo debian_chroot=$1 chroot ${ROOTFS} /bin/bash
echo "umount ${ROOTFS}/data"
sudo umount  ${ROOTFS}/data
if [ "`ls -A ${ROOTFS}/data`" = "" ]; then
    echo "if necessary,please sudo rm -rf ${ROOTFS}"
else
    echo "${ROOTFS}/data is not empty,please umount ${ROOTFS}/data"
fi
