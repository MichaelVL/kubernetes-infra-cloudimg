#!/bin/bash

set -eux

# https://docs.openstack.org/image-guide/openstack-images.html
sed -i 's/#GRUB_TERMINAL=.*/GRUB_TERMINAL=console/' /etc/default/grub
sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT=.*/GRUB_CMDLINE_LINUX_DEFAULT=\"console=tty0 console=ttyS0,115200n8\"/' /etc/default/grub

echo "--> Updating grub"
update-grub
