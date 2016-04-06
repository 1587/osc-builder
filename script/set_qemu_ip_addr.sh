#!/bin/sh
export PATH=$PATH:/bin/:/sbin/:/usr/bin/:/usr/sbin/
HOST_IP=`cat /proc/cmdline | awk '{for(a=1;a<=NF;a++) print $a}' | grep bridgeip | awk -F "[=]" '{print $2}'`
export HOST_IP=${HOST_IP}
GUEST_IP=`echo ${HOST_IP} |awk -F[.] '{print $1"."$2"."$3"."$4+1}'`
echo "host ip hostip:${HOST_IP} local eth0:[$GUEST_IP]"
ifconfig eth0  ${GUEST_IP} netmask 255.255.255.0
route add default gw  ${HOST_IP} eth0
