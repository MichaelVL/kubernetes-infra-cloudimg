#!/bin/bash

set -eux

apt-get install -y xfsprogs lvm2

mkdir -p /rook/storage-dir

# https://github.com/rook/rook/tree/master/cluster/examples/kubernetes/ceph
echo "--> Fetching ROOK/Ceph storage manifests"
mkdir -p /etc/kubernetes/addon-manifests/rook-ceph-storage-provisioner
cd /etc/kubernetes/addon-manifests/rook-ceph-storage-provisioner

curl -O https://raw.githubusercontent.com/rook/rook/master/cluster/examples/kubernetes/ceph/common.yaml
curl -O https://raw.githubusercontent.com/rook/rook/master/cluster/examples/kubernetes/ceph/operator.yaml
curl -O https://raw.githubusercontent.com/rook/rook/master/cluster/examples/kubernetes/ceph/cluster.yaml
curl -O https://raw.githubusercontent.com/rook/rook/master/cluster/examples/kubernetes/ceph/storageclass.yaml

curl -O https://raw.githubusercontent.com/rook/rook/master/cluster/examples/kubernetes/ceph/toolbox.yaml

CEPH_VER=$(grep 'image\:' cluster.yaml | cut -d':' -f3)

sed -i -e 's|    #directories:|    directories:|' cluster.yaml
sed -i -e 's|    #- path: /var/lib/rook|    - path: /rook/storage-dir|' cluster.yaml

echo "--> Pulling ROOK/Ceph images (CEPH version $CEPH_VER)"
crictl pull rook/ceph:master
crictl pull ceph/ceph:$CEPH_VER
