#!/bin/bash

set -e

if [ `sysctl -n net.ipv4.ip_forward` -eq "1" ]; then
    echo "Forwarding configured .......... OK"
else
    echo "** Forwarding configuration ERROR"
    exit -1
fi

if [ `sysctl -n net.bridge.bridge-nf-call-iptables` -eq "1" ]; then
    echo "Bridged iptables configured .... OK"
else
    echo "** Iptables configuration ERROR"
    exit -1
fi

if [ `cat /etc/shadow | cut -d':' -f2 | grep -v '^[!*]' | wc -l` -eq "0" ]; then
    echo "Password disabling ............. OK"
else
    echo "** Password disabling ERROR"
    exit -1
fi

if [[ $(grep "^PermitRootLogin prohibit-password" /etc/ssh/sshd_config) ]]; then
    echo "Password-less root SSH login ... OK"
else
    echo "** Password login for root ERROR"
    exit -1
fi

if [[ $(grep "^PasswordAuthentication yes" /etc/ssh/sshd_config) ]]; then
    echo "** Password login ERROR"
    exit -1
else
    echo "Password SSH login disabled .... OK"
fi

echo "All tests passed!"
