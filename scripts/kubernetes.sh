#!/bin/bash

set -eux

echo "--> Updating packages"
apt-get update && apt-get upgrade -y && apt-get install -y curl apt-transport-https

echo "--> Installing Kubernetes repo"
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
cat <<EOF >/etc/apt/sources.list.d/kubernetes.list
deb http://apt.kubernetes.io/ kubernetes-xenial main
EOF
apt-get update
# Ubuntu docker version

echo "--> Installing docker"
apt-get install -y docker.io

apt-get install -y \
    ca-certificates \
    software-properties-common

# Docker docker version
#curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
#add-apt-repository \
#   "deb https://download.docker.com/linux/$(. /etc/os-release; echo "$ID") \
#   $(lsb_release -cs) \
#   stable"
#apt-get update && apt-get install -y docker-ce=$(apt-cache madison docker-ce | grep 17.03 | head -1 | awk '{print $3}')
echo "--> Installing Kubernetes packages (${KUBERNETES_VERSION}-${KUBERNETES_PATCHLEVEL})"
apt-get install -y ebtables ethtool socat
apt-get install -y kubelet=${KUBERNETES_VERSION}-${KUBERNETES_PATCHLEVEL} kubeadm=${KUBERNETES_VERSION}-${KUBERNETES_PATCHLEVEL} kubectl kubernetes-cni
apt-mark hold kubelet kubeadm kubectl

echo "ip_vs" > /etc/modules-load.d/ip_vs.conf
echo "ip_vs_rr" >> /etc/modules-load.d/ip_vs.conf
echo "ip_vs_wrr" >> /etc/modules-load.d/ip_vs.conf
echo "ip_vs_sh" >> /etc/modules-load.d/ip_vs.conf

KUBE_MAJOR=$(echo $KUBERNETES_VERSION | cut -d. -f1)
KUBE_MINOR=$(echo $KUBERNETES_VERSION | cut -d. -f2)
KUBE_PATCH=$(echo $KUBERNETES_VERSION | cut -d. -f3)
KUBE_MM="$KUBE_MAJOR.$KUBE_MINOR"

echo "${KUBERNETES_VERSION}" > /etc/kubernetes_version

# Install crictl
CRICTL_VERSION="v1.13.0"
wget https://github.com/kubernetes-sigs/cri-tools/releases/download/$CRICTL_VERSION/crictl-$CRICTL_VERSION-linux-amd64.tar.gz
sudo tar zxvf crictl-$CRICTL_VERSION-linux-amd64.tar.gz -C /usr/local/bin
rm -f crictl-$CRICTL_VERSION-linux-amd64.tar.gz

# https://kubernetes.io/docs/reference/setup-tools/kubeadm/kubeadm-init/
# https://raw.githubusercontent.com/kubernetes/kubernetes/master/cmd/kubeadm/app/constants/constants.go
# /etc/kubernetes/manifests/
FLANNEL_VER="v0.10.0-amd64"
CALICO_VER="v3.3"
CALICO_NODE_IMG_VER="v3.3.1"
CALICO_CNI_IMG_VER="v3.3.1"
CALICO_FLANNEL_VER="v0.9.1"
WEAVE_NET_VER="v1.10"
WEAVE_NET_IMG_VER="2.4.1"

kubeadm config images pull

echo "--> Fetching add-on images and manifests"

echo "--> Fetching Calico manifests"
mkdir -p /etc/kubernetes/addon-manifests/calico
cd /etc/kubernetes/addon-manifests/calico
curl -sO https://docs.projectcalico.org/$CALICO_VER/getting-started/kubernetes/installation/hosted/rbac-kdd.yaml
curl -sO https://docs.projectcalico.org/$CALICO_VER/getting-started/kubernetes/installation/hosted/kubernetes-datastore/calico-networking/1.7/calico.yaml

echo "--> Fetching Canal manifests"
mkdir -p /etc/kubernetes/addon-manifests/canal
cd /etc/kubernetes/addon-manifests/canal
curl -sO https://docs.projectcalico.org/$CALICO_VER/getting-started/kubernetes/installation/hosted/canal/rbac.yaml
curl -sO https://docs.projectcalico.org/$CALICO_VER/getting-started/kubernetes/installation/hosted/canal/canal.yaml

echo "--> Pulling Calico/Canal images"
docker pull quay.io/calico/node:$CALICO_NODE_IMG_VER
docker pull quay.io/calico/cni:$CALICO_CNI_IMG_VER
docker pull quay.io/coreos/flannel:$CALICO_FLANNEL_VER

echo "--> Fetching Flannel manifests"
mkdir -p /etc/kubernetes/addon-manifests/flannel
cd /etc/kubernetes/addon-manifests/flannel
curl -sO https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml

echo "--> Fetching Flannel image"
docker pull quay.io/coreos/flannel:$FLANNEL_VER

echo "--> Fetching Weave-net manifests"
mkdir -p /etc/kubernetes/addon-manifests/weave-net
cd /etc/kubernetes/addon-manifests/weave-net
curl -O https://cloud.weave.works/k8s/$WEAVE_NET_VER/net.yaml

echo "--> Fetching Weave-net image"
docker pull docker.io/weaveworks/weave-kube:$WEAVE_NET_IMG_VER
docker pull docker.io/weaveworks/weave-npc:$WEAVE_NET_IMG_VER

echo "--> Pulling Dashboard images"
docker pull gcr.io/google_containers/kubernetes-dashboard-amd64:v1.7.1
docker pull gcr.io/google_containers/kubernetes-dashboard-init-amd64:v1.0.0
docker pull gcr.io/google_containers/heapster-amd64:v1.4.0
docker pull gcr.io/google_containers/heapster-influxdb-amd64:v1.3.3
docker pull gcr.io/google_containers/heapster-grafana-amd64:v4.4.3

echo "--> Fetching Dashboard manifests"
mkdir -p /etc/kubernetes/addon-manifests/dashboard
cd /etc/kubernetes/addon-manifests/dashboard
curl -sO https://raw.githubusercontent.com/kubernetes/dashboard/master/src/deploy/recommended/kubernetes-dashboard.yaml
#curl -sO https://raw.githubusercontent.com/kubernetes/heapster/master/deploy/kube-config/influxdb/heapster.yaml
#curl -sO https://raw.githubusercontent.com/kubernetes/heapster/master/deploy/kube-config/influxdb/influxdb.yaml
#curl -sO https://raw.githubusercontent.com/kubernetes/heapster/master/deploy/kube-config/influxdb/grafana.yaml
#curl -sO https://raw.githubusercontent.com/kubernetes/heapster/master/deploy/kube-config/rbac/heapster-rbac.yaml
