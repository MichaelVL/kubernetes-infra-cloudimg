#!/bin/bash

set -eux

CEPH_VER="v13.2"

apt-get install -y xfsprogs

mkdir -p /rook/storage-dir

# https://github.com/rook/rook/tree/master/cluster/examples/kubernetes/ceph
echo "--> Fetching ROOK/Ceph storage manifests"
mkdir -p /etc/kubernetes/addon-manifests/rook-ceph-storage-provisioner
cd /etc/kubernetes/addon-manifests/rook-ceph-storage-provisioner

curl -O https://raw.githubusercontent.com/rook/rook/master/cluster/examples/kubernetes/ceph/operator.yaml
curl -O https://raw.githubusercontent.com/rook/rook/master/cluster/examples/kubernetes/ceph/cluster.yaml
curl -O https://raw.githubusercontent.com/rook/rook/master/cluster/examples/kubernetes/ceph/storageclass.yaml

sed -i -e "s|    image: ceph/ceph:v13|    image: ceph/ceph:$CEPH_VER|" cluster.yaml
sed -i -e 's|#    directories:|    directories:|' cluster.yaml
sed -i -e 's|#    - path: /rook/storage-dir|    - path: /rook/storage-dir|' cluster.yaml

echo "--> Pulling ROOK/Ceph images"
docker pull rook/ceph:master
docker pull ceph/ceph:$CEPH_VER
