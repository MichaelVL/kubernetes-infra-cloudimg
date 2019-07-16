#!/bin/bash

set -eux

set +e
swapuuid=$(/sbin/blkid -o value -l -s UUID -t TYPE=swap)
set -e
if [[ $swapuuid = "" ]]; then
    echo "No swap device found"
else
    swappart=$(readlink -f /dev/disk/by-uuid/$swapuuid)
    echo "  Swap partition: $swappart UUID=$swapuuid"
    /sbin/swapoff "${swappart}"
fi

/sbin/swapoff -a

echo "--> Remove swap from /etc/fstab"
sed -i '/ swap / s/^/#/' /etc/fstab
echo "--> Content of /etc/fstab"
cat /etc/fstab

# set +e
# fdisk /dev/vda <<EOF
# d
# 5
# d
# 2
# w
# EOF
# set -e

echo "--> Partitions"
fdisk -l /dev/vda
