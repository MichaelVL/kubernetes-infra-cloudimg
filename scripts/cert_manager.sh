#!/bin/bash

set -eux

echo "--> Fetching cert-manager manifests"

mkdir -p /etc/kubernetes/addon-manifests/cert-manager
cd /etc/kubernetes/addon-manifests/cert-manager
curl -sO https://raw.githubusercontent.com/jetstack/cert-manager/release-0.6/deploy/manifests/00-crds.yaml
