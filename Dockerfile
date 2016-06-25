FROM debian:8.4
ENV HOSTNAME osc
RUN SOURCES_LIST=/etc/apt/sources.list \
    && echo "deb http://ftp.cn.debian.org/debian/ jessie main non-free contrib" > ${SOURCES_LIST} \
    && echo "deb http://ftp.cn.debian.org/debian/ jessie-updates main non-free contrib" >> ${SOURCES_LIST} \
    && echo "deb-src http://ftp.cn.debian.org/debian/ jessie main non-free contrib" >> ${SOURCES_LIST} \
    && echo "deb-src http://ftp.cn.debian.org/debian/ jessie-updates main non-free contrib" >> ${SOURCES_LIST} \
    && echo "deb-src http://ftp.cn.debian.org/debian/ jessie-backports main non-free contrib" >> ${SOURCES_LIST} \
    && echo "deb-src http://ftp.cn.debian.org/debian/ jessie-backports main non-free contrib" >> ${SOURCES_LIST} \
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
    && dpkg --add-architecture arm64 \
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

#安装交叉编译环境
RUN apt-get update \
    && apt-get install -y --force-yes --no-install-recommends \
            linux-libc-dev:armel libc6-dev:armel libcap-dev:armel libmount-dev:armel libdbus-1-dev:armel \
            libgcc-4.9-dev:armel libgcc-4.9-dev:armel libstdc++-4.9-dev:armel \
            linux-libc-dev:powerpc libc6-dev:powerpc libcap-dev:powerpc libmount-dev:powerpc \
            libdbus-1-dev:powerpc libgcc-4.9-dev:powerpc libstdc++-4.9-dev:powerpc \
            linux-libc-dev:arm64 libc6-dev:arm64 libcap-dev:arm64 libmount-dev:arm64 libdbus-1-dev:arm64 \
            libgcc-4.9-dev:arm64 libgcc-4.9-dev:arm64 libstdc++-4.9-dev:arm64 \
            crossbuild-essential-armel crossbuild-essential-arm64  crossbuild-essential-powerpc \
    && apt-get -y --force-yes --no-install-recommends autoremove \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists


##安装32位库
#RUN dpkg --add-architecture i386 \
#    && apt-get update \
#    && apt-get install -y --force-yes --no-install-recommends libstdc++6:i386 lib32z1 lib32ncurses5 \
#    && apt-get install -y --force-yes --no-install-recommends libc6-dev-i386 libc6-i386

 RUN apt-get update && apt-get install -y --no-install-recommends \
     ca-certificates \
     bzr \
     mercurial \
     procps \
     && apt-get clean \
     && rm -rf /var/lib/apt/lists
 ENV LANG C.UTF-8
 RUN { \
     echo '#!/bin/sh'; \
         echo 'set -e'; \
         echo; \
         echo 'dirname "$(dirname "$(readlink -f "$(which javac || which java)")")"'; \
 } > /usr/local/bin/docker-java-home \
     && chmod +x /usr/local/bin/docker-java-home
 ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-amd64
 ENV JAVA_VERSION 8u91
 ENV JAVA_DEBIAN_VERSION 8u91-b14-1~bpo8+1
 ENV CA_CERTIFICATES_JAVA_VERSION 20140324
 RUN set -x \
         && apt-get update \
         && apt-get install -y \
         openjdk-8-jdk="$JAVA_DEBIAN_VERSION" \
         ca-certificates-java="$CA_CERTIFICATES_JAVA_VERSION" \
         && rm -rf /var/lib/apt/lists/* \
         && [ "$JAVA_HOME" = "$(docker-java-home)" ]
 RUN /var/lib/dpkg/info/ca-certificates-java.postinst configure
ENV JENKINS_HOME /var/jenkins_home
 ENV JENKINS_SLAVE_AGENT_PORT 50000

 ARG user=jenkins
 ARG group=jenkins
 ARG uid=1000
 ARG gid=1000
 RUN groupadd -g ${gid} ${group} \
 && useradd -d "$JENKINS_HOME" -u ${uid} -g ${gid} -m -s /bin/bash ${user}
 VOLUME /var/jenkins_home
 RUN mkdir -p /usr/share/jenkins/ref/init.groovy.d
 ENV TINI_SHA 066ad710107dc7ee05d3aa6e4974f01dc98f3888
 RUN curl -fsSL https://github.com/krallin/tini/releases/download/v0.5.0/tini-static -o /bin/tini && chmod +x /bin/tini \
   && echo "$TINI_SHA  /bin/tini" | sha1sum -c -
 COPY init.groovy /usr/share/jenkins/ref/init.groovy.d/tcp-slave-agent-port.groovy
 ARG JENKINS_VERSION
 ENV JENKINS_VERSION ${JENKINS_VERSION:-1.651.3}
 ARG JENKINS_SHA
 ENV JENKINS_SHA ${JENKINS_SHA:-564e49fbd180d077a22a8c7bb5b8d4d58d2a18ce}
 RUN curl -fsSL http://repo.jenkins-ci.org/public/org/jenkins-ci/main/jenkins-war/${JENKINS_VERSION}/jenkins-war-${JENKINS_VERSION}.    war -o /usr/share/jenkins/jenkins.war \
 && echo "$JENKINS_SHA  /usr/share/jenkins/jenkins.war" | sha1sum -c -
 ENV JENKINS_UC https://updates.jenkins.io
 RUN chown -R ${user} "$JENKINS_HOME" /usr/share/jenkins/ref
 EXPOSE 8080
 EXPOSE 50000
 ENV COPY_REFERENCE_FILE_LOG $JENKINS_HOME/copy_reference_file.log

 #USER ${user}

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
