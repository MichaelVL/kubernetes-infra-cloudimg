#!/bin/bash

set -eux

# The NFS storage provisioner does not require additional NFS functionality, but
# the dynamically provisioned PVs are of type nfs and thus the nodes mounting
#these drives need NFS functionality
apt-get install -y nfs-common

# See deployment.yaml - uses hostPath
mkdir -p /srv
