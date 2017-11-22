#!/bin/bash -eux

echo "--> Fetching CNCF Kubernetes conformance test manifest"
mkdir -p /etc/kubernetes/addon-manifests/cncf-conformance-test
cd /etc/kubernetes/addon-manifests/cncf-conformance-test
curl -sO https://raw.githubusercontent.com/cncf/k8s-conformance/master/sonobuoy-conformance.yaml
