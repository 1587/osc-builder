FROM debian:8.4
ENV HOSTNAME osc
RUN SOURCES_LIST=/etc/apt/sources.list \
    && echo "deb http://ftp.cn.debian.org/debian/ jessie main non-free contrib" > ${SOURCES_LIST} \
    && echo "deb http://ftp.cn.debian.org/debian/ jessie-updates main non-free contrib" >> ${SOURCES_LIST} \
    && echo "deb-src http://ftp.cn.debian.org/debian/ jessie main non-free contrib" >> ${SOURCES_LIST} \
    && echo "deb-src http://ftp.cn.debian.org/debian/ jessie-updates main non-free contrib" >> ${SOURCES_LIST} \
    && echo "deb http://ftp.cn.debian.org/debian-security/ jessie/updates main non-free contrib" >> ${SOURCES_LIST} \
    && echo "deb-src http://ftp.cn.debian.org/debian-security/ jessie/updates main non-free contrib" >> ${SOURCES_LIST} \
    && echo "deb http://emdebian.org/tools/debian jessie main extra" >> ${SOURCES_LIST} \
    && echo "deb-src http://emdebian.org/tools/debian jessie main extra" >> ${SOURCES_LIST} \
    && echo 'osc' > /etc/hostname \
    && echo '127.0.0.1 localhost' > /etc/hosts \
    && echo '127.0.1.1 osc' >> /etc/hosts \
    && echo '# The following lines are desirable for IPv6 capable hosts' >> /etc/hosts \
    && echo '::1 localhost ip6-localhost ip6-loopback' >> /etc/hosts \
    && echo 'ff02::1 ip6-allnodes' >> /etc/hosts \
    && echo 'ff02::2 ip6-allrouters' >> /etc/hosts \
    && dpkg --add-architecture armel \
    && dpkg --add-architecture armhf \
    && dpkg --add-architecture arm64 \
    && dpkg --add-architecture mips \
    && dpkg --add-architecture powerpc \
    && apt-get update \
    && apt-get install -y --force-yes --no-install-recommends wget \
    && wget http://emdebian.org/tools/debian/emdebian-toolchain-archive.key \
    && gpg --import /emdebian-toolchain-archive.key \
    && apt-key add /emdebian-toolchain-archive.key \
    && rm /emdebian-toolchain-archive.key \
    && apt-get install -y --force-yes --no-install-recommends\
               manpages manpages-dev  bash-completion  apt-utils\
               perl perl-modules \
               libtimedate-perl libdpkg-perl \
               gcc g++ \
               vim patch diffstat gawk subversion git-core colordiff file tree ctags global bc chrpath openssh-client \
               python curl wget \
               lzma bzip2 xz-utils cpio ucf  \
               dos2unix docbook-xsl xsltproc \
               dh-make debhelper pbuilder quilt debootstrap sbuild devscripts \
               gfortran gnupg gperf lintian \
               dpkg-sig u-boot-tools \
               libncurses5 libncurses5-dev ncurses-dev libssl-dev libc6 libc6-dev \
               libcap-dev libmount-dev libdbus-1-dev xutils-dev libgcc-4.9-dev \
               libgcrypt11* binutils-multiarch  libfile-homedir-perl libconfig-auto-perl \
               dput emdebian-archive-keyring  fakeroot build-essential \
               qemu qemu-user-static kmod kernel-package \
               bridge-utils net-tools uml-utilities openssh-server libc-dev linux-libc-dev \
               rpm pkg-config make autoconf automake pkgconf libtool \
               intltool autotools-dev dpkg-dev patchutils alien bison flex libbison-dev \
               libfl-dev libintl-perl libtext-unidecode-perl texinfo zip unzip \
    && apt-get -y --force-yes --no-install-recommends autoremove \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists

##安装交叉编译环境
#RUN apt-get install -y --force-yes --no-install-recommends \
#            linux-libc-dev:armel libc6-dev:armel libcap-dev:armel libmount-dev:armel libdbus-1-dev:armel \
#            libgcc-4.9-dev:armel libgcc-4.9-dev:armel libstdc++-4.9-dev:armel \
#            linux-libc-dev:powerpc libc6-dev:powerpc libcap-dev:powerpc libmount-dev:powerpc \
#            libdbus-1-dev:powerpc libgcc-4.9-dev:powerpc libstdc++-4.9-dev:powerpc \
#            linux-libc-dev:arm64 libc6-dev:arm64 libcap-dev:arm64 libmount-dev:arm64 libdbus-1-dev:arm64 \
#            libgcc-4.9-dev:arm64 libgcc-4.9-dev:arm64 libstdc++-4.9-dev:arm64 \
#            crossbuild-essential-armel crossbuild-essential-arm64  crossbuild-essential-powerpc
#
#
##安装32位库
#RUN dpkg --add-architecture i386 \
#    && apt-get update \
#    && apt-get install -y --force-yes --no-install-recommends libstdc++6:i386 lib32z1 lib32ncurses5 \
#    && apt-get install -y --force-yes --no-install-recommends libc6-dev-i386 libc6-i386

#COPY hosts /etc/hosts

#dash->bash
RUN rm /bin/sh \
    && ln -s /bin/bash /bin/sh

RUN apt-get update \
    && echo '#!/bin/bash' > /tmp/install_sudo.sh \
    && echo 'apt-get install -y --no-install-recommends sudo <<EOF' >> /tmp/install_sudo.sh \
    && echo 'Y' >> /tmp/install_sudo.sh \
    && echo 'EOF' >> /tmp/install_sudo.sh \
    && chmod 777 /tmp/install_sudo.sh \
    && source /tmp/install_sudo.sh \
    && rm /tmp/install_sudo.sh \
    && apt-get -y --force-yes --no-install-recommends autoremove \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists

RUN useradd --shell /bin/bash -m  osc-builder \
    && echo 'osc-builder ALL=(ALL:ALL) ALL' >> /etc/sudoers \
    && echo '#!/bin/sh' > /tmp/adduser_osc-builder.sh \
    && echo 'passwd osc-builder <<EOF' >> /tmp/adduser_osc-builder.sh \
    && echo 'osc-builder' >> /tmp/adduser_osc-builder.sh \
    && echo 'osc-builder' >> /tmp/adduser_osc-builder.sh \
    && echo 'EOF' >> /tmp/adduser_osc-builder.sh \
    && echo 'passwd root <<EOF2' >> /tmp/adduser_osc-builder.sh \
    && echo 'root' >> /tmp/adduser_osc-builder.sh \
    && echo 'root' >> /tmp/adduser_osc-builder.sh \
    && echo 'EOF2' >> /tmp/adduser_osc-builder.sh \
    && chmod 777 /tmp/adduser_osc-builder.sh \
    && source /tmp/adduser_osc-builder.sh \
    && rm /tmp/adduser_osc-builder.sh
COPY script/create_qemu_rootfs.sh /create_qemu_rootfs.sh

RUN mkdir /usr/src/packages
RUN chown -R osc-builder:osc-builder /usr/src/packages
RUN sh -c 'sed -ie "s/^UsePAM yes/UsePAM no/" /etc/ssh/sshd_config'
#清理工作
RUN apt-get -y --force-yes --no-install-recommends autoremove \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists
ENTRYPOINT bash /create_qemu_rootfs.sh
RUN sh -c 'echo "V1587_`date +'%Y-%m-%d-%H-%M'`" > /osc-builder-version'
RUN cat /osc-builder-version
MAINTAINER ZhuJiafa, zjfscu@gmail.com
