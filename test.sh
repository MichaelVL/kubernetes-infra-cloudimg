#!/bin/bash

set -e

TESTS_FAILED=0

if [ `sysctl -n net.ipv4.ip_forward` -eq "1" ]; then
    echo "Forwarding configured .......... OK"
else
    echo "** Forwarding configuration ERROR"
    TESTS_FAILED=1
fi

if [ `sysctl -n net.bridge.bridge-nf-call-iptables` -eq "1" ]; then
    echo "Bridged iptables configured .... OK"
else
    echo "** Iptables configuration ERROR"
    TESTS_FAILED=1
fi

if [ `cat /etc/shadow | cut -d':' -f2 | grep -v '^[!*]' | wc -l` -eq "0" ]; then
    echo "Password disabling ............. OK"
else
    echo "** Password disabling ERROR"
    TESTS_FAILED=1
fi

if [[ $(grep "^PermitRootLogin prohibit-password" /etc/ssh/sshd_config) ]]; then
    echo "Password-less root SSH login ... OK"
else
    echo "** Password login for root ERROR"
    TESTS_FAILED=1
fi

if [[ $(grep "^PasswordAuthentication yes" /etc/ssh/sshd_config) ]]; then
    echo "** Password login ERROR"
    TESTS_FAILED=1
else
    echo "Password SSH login disabled .... OK"
fi

NUM_IMAGES=$(sudo docker images |cut -f1 -d' '|wc -l)
NUM_UNIQUE_IMAGES=$(sudo docker images |cut -f1 -d' '|sort -u |wc -l)
if [[ $NUM_UNIQUE_IMAGES -eq NUM_IMAGES ]]; then
    echo "Images uniqueness check ........ OK"
else
    echo "** Multiple versions of the same image present ($NUM_UNIQUE_IMAGES/$NUM_IMAGES)"
    TESTS_FAILED=1
fi

if [[ $TESTS_FAILED -eq 0 ]]; then
    echo "All tests passed!"
else
    echo "** Tests failed!!"
    exit -1
fi
