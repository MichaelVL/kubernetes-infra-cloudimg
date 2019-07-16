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

echo "--> Installing containerd"
apt-get install -y containerd
echo "runtime-endpoint: unix:///run/containerd/containerd.sock" > /etc/crictl.yaml
echo br_netfilter >> /etc/modules
cat <<EOF >>  /etc/sysctl.d/k8s.conf
net.ipv4.ip_forward = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF

#echo "--> Installing docker"
#apt-get install -y docker.io

apt-get install -y \
    ca-certificates \
    software-properties-common

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
# https://github.com/kubernetes-sigs/cri-tools/releases
CRICTL_VERSION="v1.14.0"
wget -q https://github.com/kubernetes-sigs/cri-tools/releases/download/$CRICTL_VERSION/crictl-$CRICTL_VERSION-linux-amd64.tar.gz
tar zxf crictl-$CRICTL_VERSION-linux-amd64.tar.gz -C /usr/local/bin
rm -f crictl-$CRICTL_VERSION-linux-amd64.tar.gz

# https://github.com/coreos/flannel/releases
# https://github.com/coreos/flannel/blob/master/Documentation/kube-flannel.yml
FLANNEL_VER="v0.11.0-amd64"
# https://docs.projectcalico.org/v3.5/getting-started/kubernetes/
CALICO_VER="v3.5"
# From https://docs.projectcalico.org/$CALICO_VER/getting-started/kubernetes/installation/hosted/kubernetes-datastore/calico-networking/1.7/calico.yaml
CALICO_NODE_IMG_VER="v3.5.0"
CALICO_CNI_IMG_VER="v3.5.0"
# For use with Canal, from https://docs.projectcalico.org/$CALICO_VER/getting-started/kubernetes/installation/hosted/canal/canal.yaml
CALICO_FLANNEL_VER="v0.9.1"
WEAVE_NET_VER="v$KUBE_MM"
# From https://cloud.weave.works/k8s/$WEAVE_NET_VER/net.yaml
WEAVE_NET_IMG_VER="2.5.1"

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
crictl pull quay.io/calico/node:$CALICO_NODE_IMG_VER
crictl pull quay.io/calico/cni:$CALICO_CNI_IMG_VER
crictl pull quay.io/coreos/flannel:$CALICO_FLANNEL_VER

echo "--> Fetching Flannel manifests"
mkdir -p /etc/kubernetes/addon-manifests/flannel
cd /etc/kubernetes/addon-manifests/flannel
curl -sO https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml

echo "--> Fetching Flannel image"
crictl pull quay.io/coreos/flannel:$FLANNEL_VER

echo "--> Fetching Weave-net manifests"
mkdir -p /etc/kubernetes/addon-manifests/weave-net
cd /etc/kubernetes/addon-manifests/weave-net
curl -LsO https://cloud.weave.works/k8s/$WEAVE_NET_VER/net.yaml

echo "--> Fetching Weave-net image"
crictl pull docker.io/weaveworks/weave-kube:$WEAVE_NET_IMG_VER
crictl pull docker.io/weaveworks/weave-npc:$WEAVE_NET_IMG_VER
