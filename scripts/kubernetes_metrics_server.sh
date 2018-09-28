#!/bin/bash

set -eux

# https://github.com/kubernetes-incubator/metrics-server
echo "--> Fetching metrics-server manifests"
mkdir -p /etc/kubernetes/addon-manifests/metrics-server
cd /etc/kubernetes/addon-manifests/metrics-server

curl -O https://raw.githubusercontent.com/kubernetes-incubator/metrics-server/master/deploy/1.8%2B/auth-delegator.yaml
curl -O https://raw.githubusercontent.com/kubernetes-incubator/metrics-server/master/deploy/1.8%2B/auth-reader.yaml
curl -O https://raw.githubusercontent.com/kubernetes-incubator/metrics-server/master/deploy/1.8%2B/metrics-apiservice.yaml
curl -O https://raw.githubusercontent.com/kubernetes-incubator/metrics-server/master/deploy/1.8%2B/metrics-server-deployment.yaml
sed -i -e 's/imagePullPolicy: Always/imagePullPolicy: IfNotPresent/' metrics-server-deployment.yaml
curl -O https://raw.githubusercontent.com/kubernetes-incubator/metrics-server/master/deploy/1.8%2B/metrics-server-service.yaml
curl -O https://raw.githubusercontent.com/kubernetes-incubator/metrics-server/master/deploy/1.8%2B/resource-reader.yaml

# https://github.com/kubernetes-incubator/metrics-server/issues/67
cat >> metrics-server-deployment.yaml  <<EOF
        command:
        - /metrics-server
        - --kubelet-insecure-tls
EOF

echo "--> Pulling metrics-server image"
docker pull k8s.gcr.io/metrics-server-amd64:v0.3.0
