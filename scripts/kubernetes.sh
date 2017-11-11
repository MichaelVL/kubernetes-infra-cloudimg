#!/bin/bash -eux

echo "--> Installing Kubernetes packages"
apt-get update && apt-get install -y curl apt-transport-https

curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
cat <<EOF >/etc/apt/sources.list.d/kubernetes.list
deb http://apt.kubernetes.io/ kubernetes-xenial main
EOF
apt-get update
apt-get install -y docker.io
apt-get install -y ebtables ethtool socat
apt-get install -y kubelet kubeadm kubectl kubernetes-cni

KUBE_MAJOR=$(echo $KUBERNETES_VERSION | cut -d. -f1)
KUBE_MINOR=$(echo $KUBERNETES_VERSION | cut -d. -f2)
KUBE_PATCH=$(echo $KUBERNETES_VERSION | cut -d. -f3)
KUBE_MM="$KUBE_MAJOR.$KUBE_MINOR"

# https://raw.githubusercontent.com/kubernetes/kubernetes/master/cmd/kubeadm/app/constants/constants.go
# https://kubernetes.io/docs/admin/kubeadm/#custom-images
# /etc/kubernetes/manifests/
if [ "$KUBE_MM" == "1.7" ]
then
    ETC_VER="3.0.17"
    PAUSE_VER="3.0"
    DNS_VER="1.14.5"
    CANAL_VER="1.7"
fi
if [ "$KUBE_MM" == "1.8" ]
then
    ETC_VER="3.0.17"
    PAUSE_VER="3.0"
    DNS_VER="1.14.5"
    # FIXME - canal have no 1.8 manifests
    CANAL_VER="1.7"
fi

echo "--> Pulling Kubernetes container images ($KUBERNETES_VERSION)"
KUBEVER="v$KUBERNETES_VERSION"
docker pull gcr.io/google_containers/kube-apiserver-amd64:$KUBEVER
docker pull gcr.io/google_containers/kube-controller-manager-amd64:$KUBEVER
docker pull gcr.io/google_containers/kube-scheduler-amd64:$KUBEVER
docker pull gcr.io/google_containers/kube-proxy-amd64:$KUBEVER

docker pull gcr.io/google_containers/etcd-amd64:$ETC_VER

docker pull gcr.io/google_containers/pause-amd64:$PAUSE_VER
docker pull gcr.io/google_containers/k8s-dns-sidecar-amd64:$DNS_VER
docker pull gcr.io/google_containers/k8s-dns-kube-dns-amd64:$DNS_VER
docker pull gcr.io/google_containers/k8s-dns-dnsmasq-nanny-amd64:$DNS_VER

echo "--> Contents of /var/lib/kubelet"
ls /var/lib/kubelet

# https://raw.githubusercontent.com/projectcalico/canal/master/k8s-install/1.7/canal.yaml
echo "--> Pulling Calico/Canal images"
docker pull quay.io/calico/node:v2.5.1
docker pull quay.io/calico/cni:v1.10.0
docker pull quay.io/coreos/flannel:v0.8.0

echo "--> Pulling Dashboard and Helm images"
docker pull gcr.io/google_containers/kubernetes-dashboard-amd64:v1.7.1
docker pull gcr.io/google_containers/kubernetes-dashboard-init-amd64:v1.0.0
docker pull gcr.io/google_containers/heapster-amd64:v1.4.0
docker pull gcr.io/google_containers/heapster-influxdb-amd64:v1.3.3
docker pull gcr.io/kubernetes-helm/tiller:v2.4.2

echo "--> Pulling Ingress controller images"
docker pull gcr.io/google_containers/defaultbackend:1.3
docker pull gcr.io/google_containers/nginx-ingress-controller:0.9.0-beta.15

echo "--> Fetching add-on manifests"

echo "--> Fetching Dashboaard"
mkdir -p /etc/kubernetes/addon-manifests/dashboard
cd /etc/kubernetes/addon-manifests/dashboard
curl -O https://raw.githubusercontent.com/kubernetes/dashboard/master/src/deploy/recommended/kubernetes-dashboard.yaml
curl -O https://raw.githubusercontent.com/kubernetes/heapster/master/deploy/kube-config/influxdb/heapster.yaml
curl -O https://raw.githubusercontent.com/kubernetes/heapster/master/deploy/kube-config/influxdb/influxdb.yaml

echo "--> Fetching Flannel"
mkdir -p /etc/kubernetes/addon-manifests/flannel
cd /etc/kubernetes/addon-manifests/flannel
curl -O https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml

echo "--> Fetching Canal"
mkdir -p /etc/kubernetes/addon-manifests/canal
cd /etc/kubernetes/addon-manifests/canal
curl -O https://raw.githubusercontent.com/projectcalico/canal/master/k8s-install/$CANAL_VER/rbac.yaml
curl -O https://raw.githubusercontent.com/projectcalico/canal/master/k8s-install/$CANAL_VER/canal.yaml

echo "--> Images available after installing Kubernetes"
docker images

echo "--> Manifests available"
ls -R /etc/kubernetes/addon-manifests/
