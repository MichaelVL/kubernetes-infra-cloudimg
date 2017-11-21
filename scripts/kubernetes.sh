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
    FLANNEL_VER="v0.8.0"
    CANAL_VER="1.7"
    CANAL_NODE_IMG_VER="v2.6.2"
    CANAL_CNI_IMG_VER="v1.11.0"
fi
if [ "$KUBE_MM" == "1.8" ]
then
    ETC_VER="3.0.17"
    PAUSE_VER="3.0"
    DNS_VER="1.14.5"
    FLANNEL_VER="v0.8.0"
    # FIXME - canal have no 1.8 manifests
    CANAL_VER="1.7"
    CANAL_NODE_IMG_VER="v2.6.2"
    CANAL_CNI_IMG_VER="v1.11.0"
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

echo "--> Fetching add-on images and manifests"

# https://raw.githubusercontent.com/projectcalico/canal/master/k8s-install/1.7/canal.yaml
echo "--> Pulling Calico/Canal images"
docker pull quay.io/calico/node:$CANAL_NODE_IMG_VER
docker pull quay.io/calico/cni:$CANAL_CNI_IMG_VER
docker pull quay.io/coreos/flannel:$FLANNEL_VER

echo "--> Fetching Flannel manifests"
mkdir -p /etc/kubernetes/addon-manifests/flannel
cd /etc/kubernetes/addon-manifests/flannel
curl -sO https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml

echo "--> Fetching Canal manifests"
mkdir -p /etc/kubernetes/addon-manifests/canal
cd /etc/kubernetes/addon-manifests/canal
curl -sO https://raw.githubusercontent.com/projectcalico/canal/master/k8s-install/$CANAL_VER/rbac.yaml
curl -sO https://raw.githubusercontent.com/projectcalico/canal/master/k8s-install/$CANAL_VER/canal.yaml

echo "--> Pulling Dashboard and Helm images"
docker pull gcr.io/google_containers/kubernetes-dashboard-amd64:v1.7.1
docker pull gcr.io/google_containers/kubernetes-dashboard-init-amd64:v1.0.0
docker pull gcr.io/google_containers/heapster-amd64:v1.4.0
docker pull gcr.io/google_containers/heapster-influxdb-amd64:v1.3.3
docker pull gcr.io/google_containers/heapster-grafana-amd64:v4.4.3
docker pull gcr.io/kubernetes-helm/tiller:v2.4.2

echo "--> Fetching Dashboaard manifests"
mkdir -p /etc/kubernetes/addon-manifests/dashboard
cd /etc/kubernetes/addon-manifests/dashboard
curl -sO https://raw.githubusercontent.com/kubernetes/dashboard/master/src/deploy/recommended/kubernetes-dashboard.yaml
curl -sO https://raw.githubusercontent.com/kubernetes/heapster/master/deploy/kube-config/influxdb/heapster.yaml
curl -sO https://raw.githubusercontent.com/kubernetes/heapster/master/deploy/kube-config/influxdb/influxdb.yaml
curl -sO https://raw.githubusercontent.com/kubernetes/heapster/master/deploy/kube-config/influxdb/grafana.yaml
curl -sO https://raw.githubusercontent.com/kubernetes/heapster/master/deploy/kube-config/rbac/heapster-rbac.yaml

# https://github.com/kubernetes/kubernetes/tree/master/cluster/addons/fluentd-elasticsearch
echo "--> Fetching Elasticsearch, Fluentd and Kibana manifests"
mkdir -p /etc/kubernetes/addon-manifests/efk
cd /etc/kubernetes/addon-manifests/efk
curl -sO https://raw.githubusercontent.com/kubernetes/kubernetes/master/cluster/addons/fluentd-elasticsearch/es-service.yaml
curl -sO https://raw.githubusercontent.com/kubernetes/kubernetes/master/cluster/addons/fluentd-elasticsearch/es-statefulset.yaml
curl -sO https://raw.githubusercontent.com/kubernetes/kubernetes/master/cluster/addons/fluentd-elasticsearch/fluentd-es-configmap.yaml
curl -sO https://raw.githubusercontent.com/kubernetes/kubernetes/master/cluster/addons/fluentd-elasticsearch/fluentd-es-ds.yaml
curl -sO https://raw.githubusercontent.com/kubernetes/kubernetes/master/cluster/addons/fluentd-elasticsearch/kibana-deployment.yaml
curl -sO https://raw.githubusercontent.com/kubernetes/kubernetes/master/cluster/addons/fluentd-elasticsearch/kibana-service.yaml

docker pull gcr.io/google-containers/elasticsearch:v5.6.2
docker pull gcr.io/google-containers/fluentd-elasticsearch:v2.0.2
docker pull docker.elastic.co/kibana/kibana:5.6.2

# https://github.com/kubernetes/ingress-nginx/blob/master/deploy/README.md
echo "--> Pulling Ingress controller manifests"
mkdir -p /etc/kubernetes/addon-manifests/ingress
cd /etc/kubernetes/addon-manifests/ingress
curl -sO https://raw.githubusercontent.com/kubernetes/ingress-nginx/master/deploy/namespace.yaml
curl -sO https://raw.githubusercontent.com/kubernetes/ingress-nginx/master/deploy/default-backend.yaml
curl -sO https://raw.githubusercontent.com/kubernetes/ingress-nginx/master/deploy/configmap.yaml
curl -sO https://raw.githubusercontent.com/kubernetes/ingress-nginx/master/deploy/tcp-services-configmap.yaml
curl -sO https://raw.githubusercontent.com/kubernetes/ingress-nginx/master/deploy/udp-services-configmap.yaml
curl -sO https://raw.githubusercontent.com/kubernetes/ingress-nginx/master/deploy/rbac.yaml
curl -sO https://raw.githubusercontent.com/kubernetes/ingress-nginx/master/deploy/with-rbac.yaml
curl -sO https://raw.githubusercontent.com/kubernetes/ingress-nginx/master/deploy/provider/baremetal/service-nodeport.yaml

echo "--> Pulling Ingress controller images"
docker pull gcr.io/google_containers/defaultbackend:1.4
docker pull gcr.io/google_containers/nginx-ingress-controller:0.9.0-beta.17

echo "--> Fetching CNCF Kubernetes conformance test manifest"
mkdir -p /etc/kubernetes/addon-manifests/cncf-conformance-test
cd /etc/kubernetes/addon-manifests/cncf-conformance-test
curl -sO https://raw.githubusercontent.com/cncf/k8s-conformance/master/sonobuoy-conformance.yaml

echo "--> Images available after installing Kubernetes"
docker images

echo "--> Manifests available"
ls -R /etc/kubernetes/addon-manifests/
