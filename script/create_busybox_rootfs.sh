#!/bin/bash
#安装chroot编译环境
DESTDIR=`pwd`
if [ "$1" == "powerpc" ]; then
    ARCH=powerpc
    QEMU_STATIC_BIN=qemu-ppc-static
    LIB_ARCH=powerpc-linux-gnu
    OPTION="--foreign --arch ${ARCH}"
elif [ "$1" == "armel" ]; then
    ARCH=armel
    QEMU_STATIC_BIN=qemu-arm-static
    LIB_ARCH=armel-linux-gnu
    OPTION="--foreign --arch ${ARCH}"
    #OPTION="--no-resolve-deps --variant minbase --foreign --arch ${ARCH}"
elif [ "$1" == "x86_64" ]; then
    ARCH=x86_64
    QEMU_STATIC_BIN=qemu-x86_64-static
    LIB_ARCH=x86_64-linux-gnu
    OPTION="--foreign --arch amd64"
elif [ "$1" == "arm64" ]; then
    ARCH=aarch64
    QEMU_STATIC_BIN=qemu-aarch64-static
    LIB_ARCH=aarch64-linux-gnu
    OPTION="--foreign --arch arm64"
else
    echo "usage:"
    echo "       ./create_rootfs.sh {powerpc|armel|arm64|x86_64}"
    echo " "
    exit 1
fi
SUITE=jessie
TARGET=${DESTDIR}/${ARCH}-rootfs
ROOTFS_PATH=${TARGET}_mini
MIRROR=http://10.171.69.128/debian/
if [ -e /usr/bin/${QEMU_STATIC_BIN} ];then
    echo "find /usr/bin/${QEMU_STATIC_BIN} success"
else
    echo "cant find /usr/bin/${QEMU_STATIC_BIN},please:"
    echo "sudo apt-get install qemu-user-static qemu"
fi
if [ -e ${ROOTFS_PATH} ];then
    echo "please rm  ${ROOTFS_PATH} first"
fi
echo "ARCH:            ${ARCH}"
echo "QEMU_STATIC_BIN: ${QEMU_STATIC_BIN}"
echo "LIB_ARCH:        ${LIB_ARCH}"
echo "OPTION:          ${OPTION}"
echo "SUITE:           ${SUITE}"
echo "TARGET:          ${TARGET}"
echo "MIRROR:          ${MIRROR}"
echo "ROOTFS_PATH:     ${ROOTFS_PATH}"

sudo debootstrap ${OPTION} ${SUITE} ${TARGET} ${MIRROR} \
    && sudo cp /usr/bin/${QEMU_STATIC_BIN} ${TARGET}/usr/bin/ \
    && sudo cp /etc/apt/sources.list ${TARGET}/etc/apt/sources.list \
    && sudo DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true LC_ALL=C LANGUAGE=C LANG=C chroot ${TARGET}/ /debootstrap/debootstrap --second-stage \
    && sudo cp ..//docker/sources.list ${TARGET}/etc/apt/sources.list 
    && sudo rm ${TARGET}/usr/bin/${QEMU_STATIC_BIN}

crop_rootfs()
{
    sudo mkdir ${ROOTFS_PATH} \
        && sudo mkdir ${ROOTFS_PATH}/boot \
        && sudo mkdir ${ROOTFS_PATH}/home \
        && sudo mkdir ${ROOTFS_PATH}/lib \
        && sudo mkdir ${ROOTFS_PATH}/lib/${LIB_ARCH} \
        && sudo mkdir ${ROOTFS_PATH}/lib/init \
        && sudo mkdir ${ROOTFS_PATH}/lib/lsb \
        && sudo mkdir ${ROOTFS_PATH}/lib/udev \
        && sudo mkdir ${ROOTFS_PATH}/mnt \
        && sudo mkdir ${ROOTFS_PATH}/proc \
        && sudo mkdir ${ROOTFS_PATH}/root \
        && sudo mkdir ${ROOTFS_PATH}/run \
        && sudo mkdir ${ROOTFS_PATH}/sys \
        && sudo mkdir ${ROOTFS_PATH}/sbin \
        && sudo mkdir ${ROOTFS_PATH}/tmp \
        && sudo mkdir ${ROOTFS_PATH}/var \
        && sudo mkdir ${ROOTFS_PATH}/var/backups \
        && sudo mkdir ${ROOTFS_PATH}/var/cache \
        && sudo mkdir ${ROOTFS_PATH}/var/lib \
        && sudo mkdir ${ROOTFS_PATH}/var/pam \
        && sudo mkdir ${ROOTFS_PATH}/var/urandom \
        && sudo mkdir ${ROOTFS_PATH}/var/local \
        && sudo mkdir ${ROOTFS_PATH}/var/lock \
        && sudo mkdir ${ROOTFS_PATH}/var/log \
        && sudo mkdir ${ROOTFS_PATH}/var/log/fsck \
        && sudo mkdir ${ROOTFS_PATH}/var/run \
        && sudo mkdir ${ROOTFS_PATH}/var/spool \
        && sudo mkdir ${ROOTFS_PATH}/var/tmp \
        && sudo mkdir ${ROOTFS_PATH}/bin \
        && sudo mkdir ${ROOTFS_PATH}/usr \
        && sudo mkdir ${ROOTFS_PATH}/usr/bin \
        && sudo mkdir ${ROOTFS_PATH}/usr/sbin \
        && sudo mkdir ${ROOTFS_PATH}/usr/include \
        && sudo mkdir ${ROOTFS_PATH}/usr/lib \
        && sudo mkdir ${ROOTFS_PATH}/usr/share \
        && sudo mkdir ${ROOTFS_PATH}/usr/src

    #创建busybox的软连接
    sudo ln -s busybox ${ROOTFS_PATH}/bin/addgroup \
        && sudo ln -s busybox ${ROOTFS_PATH}/bin/adduser \
        && sudo ln -s busybox ${ROOTFS_PATH}/bin/ash \
        && sudo ln -s busybox ${ROOTFS_PATH}/bin/cat \
        && sudo ln -s busybox ${ROOTFS_PATH}/bin/chmod \
        && sudo ln -s busybox ${ROOTFS_PATH}/bin/chown \
        && sudo ln -s busybox ${ROOTFS_PATH}/bin/cp \
        && sudo ln -s busybox ${ROOTFS_PATH}/bin/date \
        && sudo ln -s busybox ${ROOTFS_PATH}/bin/dd \
        && sudo ln -s busybox ${ROOTFS_PATH}/bin/delgroup \
        && sudo ln -s busybox ${ROOTFS_PATH}/bin/deluser \
        && sudo ln -s busybox ${ROOTFS_PATH}/bin/df \
        && sudo ln -s busybox ${ROOTFS_PATH}/bin/dmesg \
        && sudo ln -s busybox ${ROOTFS_PATH}/bin/echo \
        && sudo ln -s busybox ${ROOTFS_PATH}/bin/ed \
        && sudo ln -s busybox ${ROOTFS_PATH}/bin/egrep \
        && sudo ln -s busybox ${ROOTFS_PATH}/bin/false \
        && sudo ln -s busybox ${ROOTFS_PATH}/bin/fgrep \
        && sudo ln -s busybox ${ROOTFS_PATH}/bin/grep \
        && sudo ln -s busybox ${ROOTFS_PATH}/bin/gunzip \
        && sudo ln -s busybox ${ROOTFS_PATH}/bin/hostname \
        && sudo ln -s busybox ${ROOTFS_PATH}/bin/kill \
        && sudo ln -s busybox ${ROOTFS_PATH}/bin/ln \
        && sudo ln -s busybox ${ROOTFS_PATH}/bin/login \
        && sudo ln -s busybox ${ROOTFS_PATH}/bin/ls \
        && sudo ln -s busybox ${ROOTFS_PATH}/bin/mkdir \
        && sudo ln -s busybox ${ROOTFS_PATH}/bin/mknod \
        && sudo ln -s busybox ${ROOTFS_PATH}/bin/mktemp \
        && sudo ln -s busybox ${ROOTFS_PATH}/bin/more \
        && sudo ln -s busybox ${ROOTFS_PATH}/bin/mount \
        && sudo ln -s busybox ${ROOTFS_PATH}/bin/mv \
        && sudo ln -s busybox ${ROOTFS_PATH}/bin/netstat \
        && sudo ln -s busybox ${ROOTFS_PATH}/bin/ping \
        && sudo ln -s busybox ${ROOTFS_PATH}/bin/ps \
        && sudo ln -s busybox ${ROOTFS_PATH}/bin/pwd \
        && sudo ln -s busybox ${ROOTFS_PATH}/bin/rm \
        && sudo ln -s busybox ${ROOTFS_PATH}/bin/sed \
        && sudo ln -s busybox ${ROOTFS_PATH}/bin/sleep \
        && sudo ln -s busybox ${ROOTFS_PATH}/bin/stty \
        && sudo ln -s busybox ${ROOTFS_PATH}/bin/tar \
        && sudo ln -s busybox ${ROOTFS_PATH}/bin/touch \
        && sudo ln -s busybox ${ROOTFS_PATH}/bin/true \
        && sudo ln -s busybox ${ROOTFS_PATH}/bin/umount \
        && sudo ln -s busybox ${ROOTFS_PATH}/bin/uname \
        && sudo ln -s busybox ${ROOTFS_PATH}/bin/usleep \
        && sudo ln -s busybox ${ROOTFS_PATH}/bin/vi \
        && sudo ln -s busybox ${ROOTFS_PATH}/bin/zcat \
        && sudo ln -s ../bin/busybox ${ROOTFS_PATH}/sbin/arp \
        && sudo ln -s ../bin/busybox ${ROOTFS_PATH}/sbin/athstats \
        && sudo ln -s ../bin/busybox ${ROOTFS_PATH}/sbin/athstatsclr \
        && sudo ln -s ../bin/busybox ${ROOTFS_PATH}/sbin/depmod \
        && sudo ln -s ../bin/busybox ${ROOTFS_PATH}/sbin/getty \
        && sudo ln -s ../bin/busybox ${ROOTFS_PATH}/sbin/halt \
        && sudo ln -s ../bin/busybox ${ROOTFS_PATH}/sbin/ifconfig \
        && sudo ln -s ../bin/busybox ${ROOTFS_PATH}/sbin/insmod \
        && sudo ln -s ../bin/busybox ${ROOTFS_PATH}/sbin/iwconfig \
        && sudo ln -s ../bin/busybox ${ROOTFS_PATH}/sbin/iwlist \
        && sudo ln -s ../bin/busybox ${ROOTFS_PATH}/sbin/iwpriv \
        && sudo ln -s ../bin/busybox ${ROOTFS_PATH}/sbin/losetup \
        && sudo ln -s ../bin/busybox ${ROOTFS_PATH}/sbin/lsmod \
        && sudo ln -s ../bin/busybox ${ROOTFS_PATH}/sbin/mdev \
        && sudo ln -s ../bin/busybox ${ROOTFS_PATH}/sbin/modinfo \
        && sudo ln -s ../bin/busybox ${ROOTFS_PATH}/sbin/modprobe \
        && sudo ln -s ../bin/busybox ${ROOTFS_PATH}/sbin/pktlogconf \
        && sudo ln -s ../bin/busybox ${ROOTFS_PATH}/sbin/pktlogdump \
        && sudo ln -s ../bin/busybox ${ROOTFS_PATH}/sbin/poweroff \
        && sudo ln -s ../bin/busybox ${ROOTFS_PATH}/sbin/radartool \
        && sudo ln -s ../bin/busybox ${ROOTFS_PATH}/sbin/reboot \
        && sudo ln -s ../bin/busybox ${ROOTFS_PATH}/sbin/rmmod \
        && sudo ln -s ../bin/busybox ${ROOTFS_PATH}/sbin/route \
        && sudo ln -s ../bin/busybox ${ROOTFS_PATH}/sbin/sysdbg \
        && sudo ln -s ../bin/busybox ${ROOTFS_PATH}/sbin/wlanconfig \
        && sudo ln -s ../../bin/busybox ${ROOTFS_PATH}/usr/bin/[ \
        && sudo ln -s ../../bin/busybox ${ROOTFS_PATH}/usr/bin/[[ \
        && sudo ln -s ../../bin/busybox ${ROOTFS_PATH}/usr/bin/arping \
        && sudo ln -s ../../bin/busybox ${ROOTFS_PATH}/usr/bin/awk \
        && sudo ln -s ../../bin/busybox ${ROOTFS_PATH}/usr/bin/bunzip2 \
        && sudo ln -s ../../bin/busybox ${ROOTFS_PATH}/usr/bin/bzcat \
        && sudo ln -s ../../bin/busybox ${ROOTFS_PATH}/usr/bin/bzip2 \
        && sudo ln -s ../../bin/busybox ${ROOTFS_PATH}/usr/bin/cut \
        && sudo ln -s ../../bin/busybox ${ROOTFS_PATH}/usr/bin/du \
        && sudo ln -s ../../bin/busybox ${ROOTFS_PATH}/usr/bin/find \
        && sudo ln -s ../../bin/busybox ${ROOTFS_PATH}/usr/bin/free \
        && sudo ln -s ../../bin/busybox ${ROOTFS_PATH}/usr/bin/head \
        && sudo ln -s ../../bin/busybox ${ROOTFS_PATH}/usr/bin/id \
        && sudo ln -s ../../bin/busybox ${ROOTFS_PATH}/usr/bin/killall \
        && sudo ln -s ../../bin/busybox ${ROOTFS_PATH}/usr/bin/killall5 \
        && sudo ln -s ../../bin/busybox ${ROOTFS_PATH}/usr/bin/lspci \
        && sudo ln -s ../../bin/busybox ${ROOTFS_PATH}/usr/bin/passwd \
        && sudo ln -s ../../bin/busybox ${ROOTFS_PATH}/usr/bin/readahead \
        && sudo ln -s ../../bin/busybox ${ROOTFS_PATH}/usr/bin/sort \
        && sudo ln -s ../../bin/busybox ${ROOTFS_PATH}/usr/bin/tail \
        && sudo ln -s ../../bin/busybox ${ROOTFS_PATH}/usr/bin/tee \
        && sudo ln -s ../../bin/busybox ${ROOTFS_PATH}/usr/bin/test \
        && sudo ln -s ../../bin/busybox ${ROOTFS_PATH}/usr/bin/top \
        && sudo ln -s ../../bin/busybox ${ROOTFS_PATH}/usr/bin/uptime \
        && sudo ln -s ../../bin/busybox ${ROOTFS_PATH}/usr/bin/whoami \
        && sudo ln -s ../../bin/busybox ${ROOTFS_PATH}/usr/bin/xargs \
        && sudo ln -s ../../bin/busybox ${ROOTFS_PATH}/usr/bin/yes \
        && sudo ln -s ../../bin/busybox ${ROOTFS_PATH}/usr/sbin/chpasswd \
        && sudo ln -s ../../bin/busybox ${ROOTFS_PATH}/usr/sbin/nbd-client \
        && sudo ln -s ../../bin/busybox ${ROOTFS_PATH}/usr/sbin/ntpd \
        && sudo ln -s ../../bin/busybox ${ROOTFS_PATH}/usr/sbin/telnetd \
        && sudo ln -s ../../bin/busybox ${ROOTFS_PATH}/usr/sbin/addgroup \
        && sudo ln -s ../../bin/busybox ${ROOTFS_PATH}/usr/sbin/adduser \
        && sudo ln -s ../../bin/busybox ${ROOTFS_PATH}/usr/sbin/delgroup \
        && sudo ln -s ../../bin/busybox ${ROOTFS_PATH}/usr/sbin/deluser

    sudo cp -rf ${TARGET}/sbin/agetty ${ROOTFS_PATH}/sbin/ \
        && sudo cp -rf ${TARGET}/sbin/runlevel ${ROOTFS_PATH}/sbin/ \
        && sudo cp -rf ${TARGET}/sbin/sulogin ${ROOTFS_PATH}/sbin/ \
        && sudo cp -rf ${TARGET}/usr/bin/getent ${ROOTFS_PATH}/usr/bin/ \
        && sudo ln -s /bin/busybox ${ROOTFS_PATH}/init  \
        && sudo cp -rf ${TARGET}/bin/bash ${ROOTFS_PATH}/bin/ \
        && sudo ln -s /bin/bash ${ROOTFS_PATH}/bin/sh \
        && sudo cp -rf ${TARGET}/dev ${ROOTFS_PATH}/  \
        && sudo cp -rf ${TARGET}/etc ${ROOTFS_PATH}/ 


    sudo rm -rf ${ROOTFS_PATH}/etc/apt 
    sudo rm -rf ${ROOTFS_PATH}/etc/cron.* 
    sudo rm -rf ${ROOTFS_PATH}/etc/crontab 
    sudo rm -rf ${ROOTFS_PATH}/etc/debconf.conf 
    sudo rm -rf ${ROOTFS_PATH}/etc/dpkg 
    sudo rm -rf ${ROOTFS_PATH}/etc/vim

    #创建lib
    sudo cp -rf ${TARGET}/lib/terminfo ${ROOTFS_PATH}/lib/ \
        && sudo cp -rf ${TARGET}/lib/udev/hwclock-set ${ROOTFS_PATH}/lib/udev/ \
        && sudo cp -rf ${TARGET}/lib/udev/rules.d ${ROOTFS_PATH}/lib/udev/ \
        && sudo cp -rf ${TARGET}/lib/lsb/init-functions ${ROOTFS_PATH}/lib/lsb/ \
        && sudo cp -rf ${TARGET}/lib/lsb/init-functions.d ${ROOTFS_PATH}/lib/lsb/ \
        && sudo cp -rf ${TARGET}/lib/init/bootclean.sh ${ROOTFS_PATH}/lib/init/ \
        && sudo cp -rf ${TARGET}/lib/init/mount-functions.sh ${ROOTFS_PATH}/lib/init/ \
        && sudo cp -rf ${TARGET}/lib/init/swap-functions.sh ${ROOTFS_PATH}/lib/init/ \
        && sudo cp -rf ${TARGET}/lib/init/tmpfs.sh ${ROOTFS_PATH}/lib/init/ \
        && sudo cp -rf ${TARGET}/lib/init/vars.sh ${ROOTFS_PATH}/lib/init/ 

    sudo cp -rf ${TARGET}/lib/$LIB_ARCH/ld-*.so* \
        ${TARGET}/lib/$LIB_ARCH/libacl-*.so \
        ${TARGET}/lib/$LIB_ARCH/libacl.so* \
        ${TARGET}/lib/$LIB_ARCH/libattr-*.so  \
        ${TARGET}/lib/$LIB_ARCH/libattr.so*  \
        ${TARGET}/lib/$LIB_ARCH/libblkid-*.so \
        ${TARGET}/lib/$LIB_ARCH/libblkid.so* \
        ${TARGET}/lib/$LIB_ARCH/libcap-*so \
        ${TARGET}/lib/$LIB_ARCH/libcap.so* \
        ${TARGET}/lib/$LIB_ARCH/libcrypt-*.so \
        ${TARGET}/lib/$LIB_ARCH/libcrypt.so* \
        ${TARGET}/lib/$LIB_ARCH/libc-*.so* \
        ${TARGET}/lib/$LIB_ARCH/libc.so* \
        ${TARGET}/lib/$LIB_ARCH/libdl-*.so  \
        ${TARGET}/lib/$LIB_ARCH/libdl.so*  \
        ${TARGET}/lib/$LIB_ARCH/libgcc_s-*.so \
        ${TARGET}/lib/$LIB_ARCH/libgcc_s.so* \
        ${TARGET}/lib/$LIB_ARCH/libmemusage-*.so \
        ${TARGET}/lib/$LIB_ARCH/libmemusage.so* \
        ${TARGET}/lib/$LIB_ARCH/libmount-*.so \
        ${TARGET}/lib/$LIB_ARCH/libmount.so* \
        ${TARGET}/lib/$LIB_ARCH/libm-*.so \
        ${TARGET}/lib/$LIB_ARCH/libm.so* \
        ${TARGET}/lib/$LIB_ARCH/libncurses-*.so \
        ${TARGET}/lib/$LIB_ARCH/libncurses.so* \
        ${TARGET}/lib/$LIB_ARCH/libncursesw-*.so \
        ${TARGET}/lib/$LIB_ARCH/libncursesw.so* \
        ${TARGET}/lib/$LIB_ARCH/libnsl-*.so \
        ${TARGET}/lib/$LIB_ARCH/libnsl.so* \
        ${TARGET}/lib/$LIB_ARCH/libpcprofile-*.so \
        ${TARGET}/lib/$LIB_ARCH/libpcprofile.so* \
        ${TARGET}/lib/$LIB_ARCH/libpcre-*.so \
        ${TARGET}/lib/$LIB_ARCH/libpcre.so* \
        ${TARGET}/lib/$LIB_ARCH/libpthread-*.so \
        ${TARGET}/lib/$LIB_ARCH/libpthread.so* \
        ${TARGET}/lib/$LIB_ARCH/libresolv-*.so \
        ${TARGET}/lib/$LIB_ARCH/libresolv.so* \
        ${TARGET}/lib/$LIB_ARCH/librt-*.so \
        ${TARGET}/lib/$LIB_ARCH/librt.so* \
        ${TARGET}/lib/$LIB_ARCH/libselinux-*.so \
        ${TARGET}/lib/$LIB_ARCH/libselinux.so* \
        ${TARGET}/lib/$LIB_ARCH/libthread_db-*.so \
        ${TARGET}/lib/$LIB_ARCH/libthread_db.so* \
        ${TARGET}/lib/$LIB_ARCH/libtinfo-*.so \
        ${TARGET}/lib/$LIB_ARCH/libtinfo.so* \
        ${TARGET}/lib/$LIB_ARCH/libuuid-*.so \
        ${TARGET}/lib/$LIB_ARCH/libuuid.so* \
        ${TARGET}/lib/$LIB_ARCH/libz-*.so \
        ${TARGET}/lib/$LIB_ARCH/libz.so.* \
        ${TARGET}/lib/$LIB_ARCH/libnss_* \
        ${ROOTFS_PATH}/lib/$LIB_ARCH/ > /dev/null 2>&1
    sudo cp -rf ${TARGET}/lib/ld-*.so* ${ROOTFS_PATH}/lib/
    sudo cp -rf ${TARGET}/lib/ld.so* ${ROOTFS_PATH}/lib/
}
#crop_rootfs
