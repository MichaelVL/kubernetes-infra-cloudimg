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
curl -O https://raw.githubusercontent.com/rook/rook/master/cluster/examples/kubernetes/ceph/toolbox.yaml

cat << EOF > storageclass.yaml
apiVersion: ceph.rook.io/v1
kind: CephBlockPool
metadata:
  name: replicapool
  namespace: rook-ceph
spec:
  replicated:
    size: 3
---
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: rook-ceph-block
provisioner: ceph.rook.io/block
parameters:
  blockPool: replicapool
  # Specify the namespace of the rook cluster from which to create volumes.
  # If not specified, it will use `rook` as the default namespace of the cluster.
  # This is also the namespace where the cluster will be
  clusterNamespace: rook-ceph
  # Specify the filesystem type of the volume. If not specified, it will use `ext4`.
  fstype: xfs
  # (Optional) Specify an existing Ceph user that will be used for mounting storage with this StorageClass.
  #mountUser: user1
  # (Optional) Specify an existing Kubernetes secret name containing just one key holding the Ceph user secret.
  # The secret must exist in each namespace(s) where the storage will be consumed.
  #mountSecret: ceph-user1-secret
EOF

CEPH_VER=$(grep 'image\:' cluster.yaml | cut -d':' -f3)

sed -i -e 's|    #directories:|    directories:|' cluster.yaml
sed -i -e 's|    #- path: /var/lib/rook|    - path: /rook/storage-dir|' cluster.yaml

echo "--> Pulling ROOK/Ceph images (CEPH version $CEPH_VER)"
crictl pull rook/ceph:master
crictl pull ceph/ceph:$CEPH_VER
