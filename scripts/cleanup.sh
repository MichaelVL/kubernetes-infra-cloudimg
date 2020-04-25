#!/bin/bash

set -eux

echo "--> Images available after installing Kubernetes"
crictl images

echo "--> Image count"
crictl images -q | wc -l

echo "--> Remove udev rules"
rm -rf /dev/.udev/
rm -f /lib/udev/rules.d/75-persistent-net-generator.rules

echo "--> Remove dhcp leases"
rm -f /var/lib/dhcp/*

echo "--> Remove tmp"
rm -rf /tmp/*

echo "--> Cleanup apt cache"
apt-get -y autoremove --purge
apt-get -y clean
apt-get -y autoclean

echo "--> Remove ssh client directories"
rm -rf /home/*/.ssh
rm -rf /root/.ssh

echo "--> Remove ssh server keys"
rm -rf /etc/ssh/*_host_*

echo "--> Remove package manager cache"
apt-get clean

echo "--> Remove machine ID"
> /etc/machine-id
> /var/lib/dbus/machine-id

echo "--> Truncate log files"
truncate -s 0 /var/log/*log

echo "--> Zero unused disk space"
set +e
dd if=/dev/zero of=/zap bs=1M; rm -f /zap; echo "Zero-filling OK"
set -e

echo "--> Disk space available"
df

echo "--> Syncing..."
sync
