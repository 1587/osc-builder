#!/bin/bash
if [ -e /db/qemu.tar.gz ];then
        exit 0
fi
CURDIR=`pwd`
ARCH_ARRY=('powerpc' 'mips' 'armel' 'armhf' 'x86_64' 'aarch64')
DIR_AREY=
CHROOT="sudo DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true LC_ALL=C LANGUAGE=C LANG=C chroot "
CHANGE_ROOT_PASSWD=change_root_passwd.sh
MIRROR=http://ftp.cn.debian.org/debian
SOURCES_LIST=sources.list
change_passwd()
{
    echo '#!/bin/sh' > ${CHANGE_ROOT_PASSWD} \
    echo 'passwd root <<EOF' >> ${CHANGE_ROOT_PASSWD} \
    echo 'root' >> ${CHANGE_ROOT_PASSWD} \
    echo 'root' >> ${CHANGE_ROOT_PASSWD} \
    echo 'EOF' >> ${CHANGE_ROOT_PASSWD} \
    chmod 755 ${CHANGE_ROOT_PASSWD} \
    ls -alh ${CHANGE_ROOT_PASSWD}
    cat ${CHANGE_ROOT_PASSWD}
}
generate_sources_list()
{
    echo "deb http://ftp.cn.debian.org/debian/ jessie main non-free contrib" > ${SOURCES_LIST}
    echo "deb http://ftp.cn.debian.org/debian/ jessie-updates main non-free contrib" >> ${SOURCES_LIST}
    echo "deb-src http://ftp.cn.debian.org/debian/ jessie main non-free contrib" >> ${SOURCES_LIST}
    echo "deb-src http://ftp.cn.debian.org/debian/ jessie-updates main non-free contrib" >> ${SOURCES_LIST}
    echo "deb http://ftp.cn.debian.org/debian-security/ jessie/updates main non-free contrib" >> ${SOURCES_LIST}
    echo "deb-src http://ftp.cn.debian.org/debian-security/ jessie/updates main non-free contrib" >> ${SOURCES_LIST}
    cat ${SOURCES_LIST}
}
create_chroot_rootfs()
{
    if [ "X$1" == "X" ]; then
        echo "create_chroot_rootfs failed";
        exit 1;
    fi 
    local local_arch=$1;
    if [ "${local_arch}" == "powerpc" ]; then
        local DEBOOTSTRAP_ARCH=powerpc;
        local ROOTFS_ARCH=powerpc;
        local QEMU_BIN=qemu-ppc-static;
    elif [ "${local_arch}" == "aarch64" ]; then
        local DEBOOTSTRAP_ARCH=arm64;
        local ROOTFS_ARCH=aarch64;
        local QEMU_BIN=qemu-aarch64-static;
    elif [ "${local_arch}" == "armel" ]; then
        local DEBOOTSTRAP_ARCH=armel;
        local ROOTFS_ARCH=armel;
        local QEMU_BIN=qemu-arm-static;
    elif [ "${local_arch}" == "armhf" ]; then
        local DEBOOTSTRAP_ARCH=armhf;
        local ROOTFS_ARCH=armhf;
        local QEMU_BIN=qemu-arm-static;
    elif [ "${local_arch}" == "mips" ]; then
        local DEBOOTSTRAP_ARCH=mips;
        local ROOTFS_ARCH=mips;
        local QEMU_BIN=qemu-mips-static;
    elif [ "${local_arch}" == "x86_64" ]; then
        local DEBOOTSTRAP_ARCH=amd64;
        local ROOTFS_ARCH=x86_64;
        local QEMU_BIN=qemu-x86_64-static;
    else
        echo "arch error $1"
        echo "usage:";
        echo "     set_env ${ARCH_ARRY[*]} ";
        exit 1
    fi
    LOCAL_CHROOT="${CHROOT} /${CURDIR}/${ROOTFS_ARCH}-chroot/"
    echo " $1 DEBOOTSTRAP_ARCH=${DEBOOTSTRAP_ARCH}  ROOTFS_ARCH=${ROOTFS_ARCH} QEMU_BIN=${QEMU_BIN}";
    echo "LOCAL_CHROOT=${LOCAL_CHROOT}"
    echo "sudo debootstrap --foreign --arch ${DEBOOTSTRAP_ARCH} jessie /${CURDIR}/${ROOTFS_ARCH}-chroot ${MIRROR}"
    sudo debootstrap --foreign --arch ${DEBOOTSTRAP_ARCH} jessie /${CURDIR}/${ROOTFS_ARCH}-chroot ${MIRROR} \
        && sudo cp /usr/bin/${QEMU_BIN} /${CURDIR}/${ROOTFS_ARCH}-chroot/usr/bin/ \
        && sudo cp ${SOURCES_LIST} /${CURDIR}/${ROOTFS_ARCH}-chroot/etc/apt/sources.list \
        && sudo cp ${CHANGE_ROOT_PASSWD} /${CURDIR}/${ROOTFS_ARCH}-chroot/ \
        && ${LOCAL_CHROOT} /debootstrap/debootstrap --second-stage \
        && sudo cp ${SOURCES_LIST} /${CURDIR}/${ROOTFS_ARCH}-chroot/etc/apt/sources.list \
        && ${LOCAL_CHROOT} bash /${CHANGE_ROOT_PASSWD} \
        && ${LOCAL_CHROOT} apt-get update \
        && ${LOCAL_CHROOT} apt-get -y --force-yes  build-dep tree \
        && ${LOCAL_CHROOT} apt-get clean \
        && ${LOCAL_CHROOT} rm -rf /var/lib/apt/lists \
        && cd /${CURDIR}/${ROOTFS_ARCH}-chroot/ \
        && sudo sh -c "find . | cpio -o -H newc | gzip >/tmp/${ROOTFS_ARCH}.cpio.gz" \
        && mkdir /${CURDIR}/${arch}-qemu \
        && cp /tmp/${ROOTFS_ARCH}.cpio.gz  /${CURDIR}/${arch}-qemu/rootfs.cpio.gz \
        && cd /${CURDIR} \
        && ls -alh /${CURDIR}/${arch}-qemu/rootfs.cpio.gz  \
        && rm /tmp/${ROOTFS_ARCH}.cpio.gz \
        && rm -rf /${CURDIR}/${ROOTFS_ARCH}-chroot \
        && echo "create /${CURDIR}/${ROOTFS_ARCH}-chroot/ success"
    local DEBOOTSTRAP_ARCH=
    local ROOTFS_ARCH=
    local QEMU_BIN=
}
change_passwd
generate_sources_list
for arch in ${ARCH_ARRY[*]};
do
{
    DIR_ARRY=("${DIR_ARRY[@]}" "${arch}-qemu")
    #DIR_ARRY=("${DIR_ARRY[@]}" "${arch}-chroot")
}
done;
echo ${DIR_ARRY[@]}
for arch in ${ARCH_ARRY[*]};
do 
{
    create_chroot_rootfs ${arch};
}&
done;
wait
sudo tar -czf /db/qemu.tar.gz ${DIR_ARRY[@]} 
rm ${SOURCES_LIST} ${CHANGE_ROOT_PASSWD} 
sudo rm -rf ${DIR_ARRY[@]} 
sudo cp /osc-builder-version /db/local_docker_version
echo "create all qemu rootfs success"
/bin/bash
