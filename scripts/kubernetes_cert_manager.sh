#!/bin/bash

set -eux

echo "--> Pulling cert-manager CRDs"
mkdir -p /etc/kubernetes/addon-manifests/cert-manager
cd /etc/kubernetes/addon-manifests/cert-manager
curl -sO https://raw.githubusercontent.com/jetstack/cert-manager/release-0.8/deploy/manifests/00-crds.yaml
