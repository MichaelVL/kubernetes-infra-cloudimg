#!/bin/bash -eux

apt-get install -y nfs-common

KUBE_MAJOR=$(echo $KUBERNETES_VERSION | cut -d. -f1)
KUBE_MINOR=$(echo $KUBERNETES_VERSION | cut -d. -f2)
KUBE_MM="$KUBE_MAJOR.$KUBE_MINOR"

# See deployment.yaml - uses hostPath
mkdir /srv

# https://github.com/kubernetes-incubator/external-storage/tree/master/nfs
echo "--> Pulling NFS storage manifests"
mkdir -p /etc/kubernetes/addon-manifests/nfs-storage-provisioner
cd /etc/kubernetes/addon-manifests/nfs-storage-provisioner
curl -O https://raw.githubusercontent.com/kubernetes-incubator/external-storage/master/nfs/deploy/kubernetes/auth/deployment-sa.yaml
curl -O https://raw.githubusercontent.com/kubernetes-incubator/external-storage/master/nfs/deploy/kubernetes/auth/daemonsett-sa.yaml
curl -O https://raw.githubusercontent.com/kubernetes-incubator/external-storage/master/nfs/deploy/kubernetes/class.yaml
curl -O https://raw.githubusercontent.com/kubernetes-incubator/external-storage/master/nfs/deploy/kubernetes/auth/serviceaccount.yaml
curl -O https://raw.githubusercontent.com/kubernetes-incubator/external-storage/master/nfs/deploy/kubernetes/auth/psp.yaml
curl -O https://raw.githubusercontent.com/kubernetes-incubator/external-storage/master/nfs/deploy/kubernetes/auth/clusterrole.yaml
curl -O https://raw.githubusercontent.com/kubernetes-incubator/external-storage/master/nfs/deploy/kubernetes/auth/clusterrolebinding.yaml

if [ "$KUBE_MM" == "1.8" ]
then
  # Moved to 'v1' in 1.8
  sed -i -e 's/apiVersion: rbac.authorization.k8s.io\/v1alpha1/apiVersion: rbac.authorization.k8s.io\/v1/' clusterrole.yaml
  sed -i -e 's/apiVersion: rbac.authorization.k8s.io\/v1alpha1/apiVersion: rbac.authorization.k8s.io\/v1/' clusterrolebinding.yaml
fi

echo "--> Pulling NFS storage image"
docker pull quay.io/kubernetes_incubator/nfs-provisioner:v1.0.8
