#!/bin/bash -eux

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
docker pull quay.io/kubernetes-ingress-controller/nginx-ingress-controller:0.9.0-beta.17
