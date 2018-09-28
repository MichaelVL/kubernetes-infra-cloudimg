#!/bin/bash

set -eux

apt-get install -y nfs-common

# See deployment.yaml - uses hostPath
mkdir -p /srv

# https://github.com/kubernetes-incubator/external-storage/tree/master/nfs
echo "--> Fetching NFS storage manifests"
mkdir -p /etc/kubernetes/addon-manifests/nfs-storage-provisioner
cd /etc/kubernetes/addon-manifests/nfs-storage-provisioner

curl -O https://raw.githubusercontent.com/kubernetes-incubator/external-storage/master/nfs/deploy/kubernetes/psp.yaml
curl -O https://raw.githubusercontent.com/kubernetes-incubator/external-storage/master/nfs/deploy/kubernetes/rbac.yaml
curl -O https://raw.githubusercontent.com/kubernetes-incubator/external-storage/master/nfs/deploy/kubernetes/deployment.yaml
curl -O https://raw.githubusercontent.com/kubernetes-incubator/external-storage/master/nfs/deploy/kubernetes/statefulset.yaml
curl -O https://raw.githubusercontent.com/kubernetes-incubator/external-storage/master/nfs/deploy/kubernetes/class.yaml
sed -i -e 's/namespace:.*/namespace: default/' rbac.yaml

echo "--> Pulling NFS storage image"
docker pull quay.io/kubernetes_incubator/nfs-provisioner:latest
