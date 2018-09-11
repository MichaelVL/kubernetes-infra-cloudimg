#!/bin/bash

set -eux

echo "--> Updating packages"
apt-get update && apt-get upgrade -y && apt-get install -y curl apt-transport-https

echo "--> Installing docker packages"
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
cat <<EOF >/etc/apt/sources.list.d/kubernetes.list
deb http://apt.kubernetes.io/ kubernetes-xenial main
EOF
apt-get update
# Ubuntu docker version
apt-get install -y docker.io

apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    software-properties-common

# Docker docker version
#curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
#add-apt-repository \
#   "deb https://download.docker.com/linux/$(. /etc/os-release; echo "$ID") \
#   $(lsb_release -cs) \
#   stable"
#apt-get update && apt-get install -y docker-ce=$(apt-cache madison docker-ce | grep 17.03 | head -1 | awk '{print $3}')

echo "--> Installing Kubernetes packages"
apt-get install -y ebtables ethtool socat
apt-get install -y kubelet kubeadm=${KUBERNETES_VERSION}-00 kubectl kubernetes-cni
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

# https://kubernetes.io/docs/reference/setup-tools/kubeadm/kubeadm-init/
# https://raw.githubusercontent.com/kubernetes/kubernetes/master/cmd/kubeadm/app/constants/constants.go
# /etc/kubernetes/manifests/
if [ "$KUBE_MM" == "1.10" ]
then
    ETC_VER="3.1.12"
    PAUSE_VER="3.1"
    DNS_VER="1.14.8"
    FLANNEL_VER="v0.10.0-amd64"
    CANAL_VER="1.7"
    CANAL_NODE_IMG_VER="v2.6.2"
    CANAL_CNI_IMG_VER="v1.11.0"
    CANAL_FLANNEL_VER="v0.9.1"
fi
if [ "$KUBE_MM" == "1.11" ]
then
    FLANNEL_VER="v0.10.0-amd64"
    CANAL_VER="v3.2"
    CANAL_NODE_IMG_VER="v3.2.1"
    CANAL_CNI_IMG_VER="v3.2.1"
    CANAL_FLANNEL_VER="v0.9.1"
fi

echo "--> Pulling Kubernetes container images ($KUBERNETES_VERSION)"
if [ "$KUBE_MM" == "1.10" ]
then
    KUBEVER="v$KUBERNETES_VERSION"
    docker pull k8s.gcr.io/kube-apiserver-amd64:$KUBEVER
    docker pull k8s.gcr.io/kube-controller-manager-amd64:$KUBEVER
    docker pull k8s.gcr.io/kube-scheduler-amd64:$KUBEVER
    docker pull k8s.gcr.io/kube-proxy-amd64:$KUBEVER

    docker pull k8s.gcr.io/etcd-amd64:$ETC_VER

    docker pull k8s.gcr.io/pause-amd64:$PAUSE_VER
    docker pull k8s.gcr.io/k8s-dns-sidecar-amd64:$DNS_VER
    docker pull k8s.gcr.io/k8s-dns-kube-dns-amd64:$DNS_VER
    docker pull k8s.gcr.io/k8s-dns-dnsmasq-nanny-amd64:$DNS_VER
fi
if [ "$KUBE_MM" == "1.11" ]
then
    kubeadm config images pull
fi

echo "--> Fetching add-on images and manifests"

echo "--> Fetching Canal manifests"
mkdir -p /etc/kubernetes/addon-manifests/canal
cd /etc/kubernetes/addon-manifests/canal
if [ "$KUBE_MM" == "1.10" ]
then
    curl -sO https://raw.githubusercontent.com/projectcalico/canal/master/k8s-install/$CANAL_VER/rbac.yaml
    curl -sO https://raw.githubusercontent.com/projectcalico/canal/master/k8s-install/$CANAL_VER/canal.yaml
else
    curl -sO https://docs.projectcalico.org/$CANAL_VER/getting-started/kubernetes/installation/hosted/canal/rbac.yaml
    curl -sO https://docs.projectcalico.org/$CANAL_VER/getting-started/kubernetes/installation/hosted/canal/canal.yaml
fi

echo "--> Pulling Calico/Canal images"
docker pull quay.io/calico/node:$CANAL_NODE_IMG_VER
docker pull quay.io/calico/cni:$CANAL_CNI_IMG_VER
docker pull quay.io/coreos/flannel:$CANAL_FLANNEL_VER

echo "--> Fetching Flannel manifests"
mkdir -p /etc/kubernetes/addon-manifests/flannel
cd /etc/kubernetes/addon-manifests/flannel
curl -sO https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml

echo "--> Fetching Flannel image"
docker pull quay.io/coreos/flannel:$FLANNEL_VER

echo "--> Pulling Dashboard and Helm images"
docker pull gcr.io/google_containers/kubernetes-dashboard-amd64:v1.7.1
docker pull gcr.io/google_containers/kubernetes-dashboard-init-amd64:v1.0.0
docker pull gcr.io/google_containers/heapster-amd64:v1.4.0
docker pull gcr.io/google_containers/heapster-influxdb-amd64:v1.3.3
docker pull gcr.io/google_containers/heapster-grafana-amd64:v4.4.3
docker pull gcr.io/kubernetes-helm/tiller:v2.9.1

echo "--> Fetching Dashboard manifests"
mkdir -p /etc/kubernetes/addon-manifests/dashboard
cd /etc/kubernetes/addon-manifests/dashboard
curl -sO https://raw.githubusercontent.com/kubernetes/dashboard/master/src/deploy/recommended/kubernetes-dashboard.yaml
curl -sO https://raw.githubusercontent.com/kubernetes/heapster/master/deploy/kube-config/influxdb/heapster.yaml
curl -sO https://raw.githubusercontent.com/kubernetes/heapster/master/deploy/kube-config/influxdb/influxdb.yaml
curl -sO https://raw.githubusercontent.com/kubernetes/heapster/master/deploy/kube-config/influxdb/grafana.yaml
curl -sO https://raw.githubusercontent.com/kubernetes/heapster/master/deploy/kube-config/rbac/heapster-rbac.yaml
