#!/bin/bash -eux

apt-get install -y cloud-init cloud-initramfs-growroot

# Ubuntu sets 'distro: ubuntu' but provides no /etc/hosts template, hence
# 'manage_etc_hosts: True' will not work.
cp /etc/cloud/templates/hosts.debian.tmpl /etc/cloud/templates/hosts.ubuntu.tmpl
