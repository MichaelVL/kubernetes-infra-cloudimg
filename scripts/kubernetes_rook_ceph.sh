#!/bin/bash

set -eux

apt-get install -y xfsprogs

# See deployment.yaml - uses hostPath
mkdir -p /srv

# https://github.com/kubernetes-incubator/external-storage/tree/master/nfs
echo "--> Fetching ROOK/Ceph storage manifests"
mkdir -p /etc/kubernetes/addon-manifests/rook-ceph-storage-provisioner
cd /etc/kubernetes/addon-manifests/rook-ceph-storage-provisioner

curl -O https://raw.githubusercontent.com/rook/rook/master/cluster/examples/kubernetes/ceph/operator.yaml
curl -O https://raw.githubusercontent.com/rook/rook/master/cluster/examples/kubernetes/ceph/cluster.yaml
curl -O https://raw.githubusercontent.com/rook/rook/master/cluster/examples/kubernetes/ceph/storageclass.yaml

sed -i -e 's|dataDirHostPath: /var/lib/rook|dataDirHostPath: /srv|' cluster.yaml

echo "--> Pulling ROOK/Ceph image"
docker pull rook/ceph:master
