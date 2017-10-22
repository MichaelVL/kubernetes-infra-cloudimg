#!/bin/bash -eux

echo "--> Remove udev rules"
rm -rf /dev/.udev/
rm /lib/udev/rules.d/75-persistent-net-generator.rules

echo "--> Remove dhcp leases"
rm /var/lib/dhcp/*

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

echo "--> Syncing..."
sync
