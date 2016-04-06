#!/bin/bash
#安装chroot编译环境
CURDIR=`pwd`
ARCH_ARRY=('powerpc')
DIR_AREY=
CHROOT="sudo DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true LC_ALL=C LANGUAGE=C LANG=C chroot "

DEBOOTSTRAP_ARCH=
ROOTFS_ARCH=
QEMU_BIN=
set_env()
{
    if [ "X$1" == "X" ]; then
        echo "set env failed";
        exit 1;
    fi 
    local_arch=$1;
    if [ "${local_arch}" == "powerpc" ]; then
        DEBOOTSTRAP_ARCH=powerpc;
        ROOTFS_ARCH=powerpc;
        QEMU_BIN=qemu-ppc-static;
    elif [ "${local_arch}" == "aarch64" ]; then
        DEBOOTSTRAP_ARCH=arm64;
        ROOTFS_ARCH=aarch64;
        QEMU_BIN=qemu-aarch64-static;
    elif [ "${local_arch}" == "armel" ]; then
        DEBOOTSTRAP_ARCH=armel;
        ROOTFS_ARCH=armel;
        QEMU_BIN=qemu-arm-static;
    elif [ "${local_arch}" == "x86_64" ]; then
        DEBOOTSTRAP_ARCH=amd64;
        ROOTFS_ARCH=x86_64;
        QEMU_BIN=qemu-x86_64-static;
    else
        echo "usage:";
        echo "     set_env ${ARCH_ARRY[*]} ";
        exit 1
    fi
    echo " $1 DEBOOTSTRAP_ARCH=${DEBOOTSTRAP_ARCH}  ROOTFS_ARCH=${ROOTFS_ARCH} QEMU_BIN=${QEMU_BIN}";
}
clear_env()
{
    DEBOOTSTRAP_ARCH=
    ROOTFS_ARCH=
    QEMU_BIN=
}

create_chroot_rootfs()
{
    if [ "X$1" == "X" ]; then
        echo "create_chroot_rootfs failed";
        exit 1;
    fi 
    set_env $1
    LOCAL_CHROOT="${CHROOT} /${CURDIR}/${ROOTFS_ARCH}-chroot/"
    sudo debootstrap --foreign --arch ${DEBOOTSTRAP_ARCH} jessie /${CURDIR}/${ROOTFS_ARCH}-chroot http://10.171.69.128/debian/ \
        && sudo cp /usr/bin/${QEMU_BIN} /${CURDIR}/${ROOTFS_ARCH}-chroot/usr/bin/ \
        && sudo cp ./sources.list /${CURDIR}/${ROOTFS_ARCH}-chroot/etc/apt/sources.list \
        && sudo cp ./change_root_passwd.sh /${CURDIR}/${ROOTFS_ARCH}-chroot/ \
        && ${LOCAL_CHROOT} /debootstrap/debootstrap --second-stage \
        && ${LOCAL_CHROOT} apt-get clean \
        && ${LOCAL_CHROOT} rm -rf /var/lib/apt/lists
    clear_env
}
for arch in ${ARCH_ARRY[*]};
do 
    create_chroot_rootfs ${arch};
    DIR_ARRY=("${DIR_ARRY[@]}" "${arch}-qemu")
    #DIR_ARRY=("${DIR_ARRY[@]}" "${arch}-chroot")
done;
echo ${DIR_ARRY[@]}
exit 0
sudo tar -czf qemu.tar.gz ${DIR_ARRY[@]}
sudo rm -rf ${DIR_ARRY[@]}
sudo  docker  build --rm  -f  Dockerfile  ./
