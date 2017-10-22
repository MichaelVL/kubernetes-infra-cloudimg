#!/bin/bash -eux

echo "--> Remove swap"
sed -i '/ swap / s/^/#/' /etc/fstab
cat /etc/fstab
