#osc container 基于debian 8 
FROM debian:jessie
ENV HOSTNAME osc

#安装docker 镜像环境
RUN echo 'deb http://ftp.cn.debian.org/debian/ jessie main non-free contrib' > /etc/apt/sources.list \
    && echo 'deb http://ftp.cn.debian.org/debian/ jessie-updates main non-free contrib' >> /etc/apt/sources.list \
    && echo 'deb-src http://ftp.cn.debian.org/debian/ jessie main non-free contrib' >> /etc/apt/sources.list \
    && echo 'deb http://ftp.cn.debian.org/debian-security/ jessie/updates main' >> /etc/apt/sources.list \
    && echo 'deb-src http://ftp.cn.debian.org/debian/ jessie-updates main non-free contrib' >> /etc/apt/sources.list \
    && echo 'deb-src http://ftp.cn.debian.org/debian-security/ jessie/updates main' >> /etc/apt/sources.list \
    && echo 'osc' > /etc/hostname \
    && echo '127.0.0.1 localhost' > /etc/hosts \
    && echo '127.0.1.1 osc' >> /etc/hosts \
    && echo '# The following lines are desirable for IPv6 capable hosts' >> /etc/hosts \
    && echo '::1 localhost ip6-localhost ip6-loopback' >> /etc/hosts \
    && echo 'ff02::1 ip6-allnodes' >> /etc/hosts \
    && echo 'ff02::2 ip6-allrouters' >> /etc/hosts \
    && apt-get update \
    && apt-get install -y --force-yes --no-install-recommends \
               manpages manpages-dev  bash-completion \
               perl perl-modules \
               libtimedate-perl libdpkg-perl \
               gcc g++ make autoconf automake libtool intltool autotools-dev \
               dpkg-dev pkg-config patchutils  \
               vim patch diffstat gawk git-core colordiff file tree ctags global bc chrpath openssh-client \
               python curl wget \
               lzma bzip2 xz-utils cpio ucf  \
               dos2unix docbook-xsl xsltproc \
               dh-make debhelper pbuilder quilt debootstrap sbuild devscripts \
               gfortran gnupg gperf lintian \
               dh-make dput dpkg-sig devscripts u-boot-tools \
               libc6-dev-i386 libc6-i386 libncurses5 libncurses5-dev ncurses-dev libssl-dev libc6 \
               libcap-dev libmount-dev libdbus-1-dev xutils-dev libgcc-4.9-dev \
               libgcrypt11* binutils-multiarch  libfile-homedir-perl libconfig-auto-perl \
               pkg-config dpkg-dev dput emdebian-archive-keyring  fakeroot build-essential \
               qemu qemu-user-static kmod kernel-package \
               bridge-utils net-tools uml-utilities 


#dash->bash
RUN rm /bin/sh \
    && ln -s /bin/bash /bin/sh 

RUN echo '#!/bin/bash' > /tmp/install_sudo.sh \
    && echo 'apt-get install -y --no-install-recommends sudo <<EOF' >> /tmp/install_sudo.sh \
    && echo 'Y' >> /tmp/install_sudo.sh \
    && echo 'EOF' >> /tmp/install_sudo.sh \
    && chmod 777 /tmp/install_sudo.sh \
    && source /tmp/install_sudo.sh \
    && rm /tmp/install_sudo.sh 

RUN useradd -m  osc-builder \
    && echo 'osc-builder ALL=(ALL:ALL) ALL' >> /etc/sudoers \
    && echo '#!/bin/sh' > /tmp/adduser_osc-builder.sh \
    && echo 'passwd osc-builder <<EOF' >> /tmp/adduser_osc-builder.sh \
    && echo 'osc-builder' >> /tmp/adduser_osc-builder.sh \
    && echo 'osc-builder' >> /tmp/adduser_osc-builder.sh \
    && echo 'EOF' >> /tmp/adduser_osc-builder.sh \
    && chmod 777 /tmp/adduser_osc-builder.sh \
    && source /tmp/adduser_osc-builder.sh \
    && rm /tmp/adduser_osc-builder.sh 

#清理工作
RUN apt-get -y --force-yes --no-install-recommends autoremove \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists
#ADD qemu.tar.gz /home
#COPY start_chroot.sh /bin/start-chroot
#COPY start_qemu.sh /bin/start-qemu
#COPY image-powerpc /home/powerpc-qemu/image
#COPY image-armel /home/armel-qemu/image
#COPY image-aarch64 /home/aarch64-qemu/image
#COPY image-x86_64 /home/x86_64-qemu/image
#COPY hosts /etc/hosts
USER osc-builder
#CMD["source /home/osc-builder/.bashrc"]

