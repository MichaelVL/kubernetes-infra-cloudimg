#!/bin/bash -eux

echo "--> Installing Kubernetes packages"
apt-get update && apt-get install -y curl apt-transport-https

curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
cat <<EOF >/etc/apt/sources.list.d/kubernetes.list
deb http://apt.kubernetes.io/ kubernetes-xenial main
EOF
apt-get update
apt-get install -y docker.io
apt-get install -y kubelet kubeadm kubectl kubernetes-cni

# https://kubernetes.io/docs/admin/kubeadm/#custom-images
# /etc/kubernetes/manifests/
if [ "$KUBERNETES_VERSION" == "1.7.6" ]
then
  echo "--> Pulling Kubernetes container images ($KUBERNETES_VERSION)"
  docker pull gcr.io/google_containers/kube-apiserver-amd64:v1.7.6
  docker pull gcr.io/google_containers/kube-controller-manager-amd64:v1.7.6
  docker pull gcr.io/google_containers/kube-scheduler-amd64:v1.7.6
  docker pull gcr.io/google_containers/kube-proxy-amd64:v1.7.6
  docker pull gcr.io/google_containers/etcd-amd64:3.0.17
  docker pull gcr.io/google_containers/pause-amd64:3.0
  docker pull gcr.io/google_containers/k8s-dns-sidecar-amd64:1.14.5
  docker pull gcr.io/google_containers/k8s-dns-kube-dns-amd64:1.14.5
  docker pull gcr.io/google_containers/k8s-dns-dnsmasq-nanny-amd64:1.14.5
fi

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

echo "--> Images available"
docker images
