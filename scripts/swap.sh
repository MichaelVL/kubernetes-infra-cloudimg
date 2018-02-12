#!/bin/bash -eux

swapuuid=$(/sbin/blkid -o value -l -s UUID -t TYPE=swap)
swappart=$(readlink -f /dev/disk/by-uuid/$swapuuid)
echo "  Swap partition: $swappart UUID=$swapuuid"
/sbin/swapoff "${swappart}"

echo "--> Remove swap"
sed -i '/ swap / s/^/#/' /etc/fstab
echo "--> Content of /etc/fstab"
cat /etc/fstab

fdisk /dev/vda <<EOF
d
5
d
2
w
EOF

echo "--> Partitions"
fdisk -l /dev/vda
