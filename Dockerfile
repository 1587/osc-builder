#osc container 基于debian 8 
FROM debian:jessie
ENV HOSTNAME osc

#还需要添加osc.builder.pub.key
#安装docker 镜像环境
#还需要添加emdebian的unstable源安装apt-get install emdebian-archive-keyring=2.0.5
    #&& echo 'deb http://10.171.69.128/emdebian/ unstable main' >> /etc/apt/sources.list \
    #&& echo 'deb-src http://10.171.69.128/emdebian/ unstable main' >> /etc/apt/sources.list \
RUN echo 'deb http://10.171.69.128/debian/ jessie main non-free contrib' > /etc/apt/sources.list \
    && echo 'deb http://10.171.69.128/debian/ jessie-updates main non-free contrib' >> /etc/apt/sources.list \
    && echo 'deb-src http://10.171.69.128/debian/ jessie main non-free contrib' >> /etc/apt/sources.list \
    && echo 'deb http://10.171.69.128/debian-security/ jessie/updates main' >> /etc/apt/sources.list \
    && echo 'deb-src http://10.171.69.128/debian/ jessie-updates main non-free contrib' >> /etc/apt/sources.list \
    && echo 'deb-src http://10.171.69.128/debian-security/ jessie/updates main' >> /etc/apt/sources.list \
    && echo 'deb http://10.171.69.128/nass/ jessie main' >> /etc/apt/sources.list \
    && echo 'deb-src http://10.171.69.128/nass/ jessie main' >> /etc/apt/sources.list \
    && echo 'deb http://10.171.69.128/nass/ unstable main' >> /etc/apt/sources.list \
    && echo 'deb-src http://10.171.69.128/nass/ unstable main' >> /etc/apt/sources.list \
    && echo 'deb http://10.171.69.128/nass/ release main' >> /etc/apt/sources.list \
    && echo 'deb-src http://10.171.69.128/nass/ release main' >> /etc/apt/sources.list \
    && echo 'deb http://10.171.69.128/emdebian/ jessie main' >> /etc/apt/sources.list \
    && echo 'deb-src http://10.171.69.128/emdebian/ jessie main' >> /etc/apt/sources.list \
    && echo 'osc' > /etc/hostname \
    && echo '127.0.0.1 localhost' > /etc/hosts \
    && echo '127.0.1.1 osc' >> /etc/hosts \
    && echo '# The following lines are desirable for IPv6 capable hosts' >> /etc/hosts \
    && echo '::1 localhost ip6-localhost ip6-loopback' >> /etc/hosts \
    && echo 'ff02::1 ip6-allnodes' >> /etc/hosts \
    && echo 'ff02::2 ip6-allrouters' >> /etc/hosts \
    && dpkg --add-architecture armel \
    && dpkg --add-architecture arm64 \
    && dpkg --add-architecture powerpc \
    && apt-get update \
    && apt-get install -y --force-yes --no-install-recommends wget \
    && wget http://10.171.69.128/nass/osc.builder.pub.key \
    && gpg --import osc.builder.pub.key \
    && apt-key add osc.builder.pub.key \
    && rm osc.builder.pub.key \
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

#安装交叉编译环境
RUN apt-get install -y --force-yes --no-install-recommends \
            libcap-dev:armel libmount-dev:armel libdbus-1-dev:armel \
            libgcc-4.9-dev:armel libgcc-4.9-dev:armel libstdc++-4.9-dev:armel \
            libcap-dev:powerpc libmount-dev:powerpc \
            libdbus-1-dev:powerpc libgcc-4.9-dev:powerpc libstdc++-4.9-dev:powerpc \
            libcap-dev:arm64 libmount-dev:arm64 libdbus-1-dev:arm64 \
            libgcc-4.9-dev:arm64 libgcc-4.9-dev:arm64 libstdc++-4.9-dev:arm64 \
            crossbuild-essential-armel crossbuild-essential-arm64  crossbuild-essential-powerpc  

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
ADD qemu.tar.gz /home
COPY start_chroot.sh /bin/start-chroot
COPY start_qemu.sh /bin/start-qemu
COPY image-powerpc /home/powerpc-qemu/image
COPY image-armel /home/armel-qemu/image
COPY image-aarch64 /home/aarch64-qemu/image
COPY image-x86_64 /home/x86_64-qemu/image
COPY hosts /etc/hosts
USER osc-builder
#CMD["source /home/osc-builder/.bashrc"]

