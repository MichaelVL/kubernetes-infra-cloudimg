#!/bin/bash

set -eux

echo "--> Fetching Contour manifests"

mkdir -p /etc/kubernetes/addon-manifests/contour
cd /etc/kubernetes/addon-manifests/contour
curl -sO https://raw.githubusercontent.com/heptio/contour/master/deployment/common/common.yaml
curl -sO https://raw.githubusercontent.com/heptio/contour/master/deployment/common/rbac.yaml
curl -sO https://raw.githubusercontent.com/heptio/contour/master/deployment/ds-hostnet/02-contour.yaml
curl -sO https://raw.githubusercontent.com/heptio/contour/master/deployment/ds-hostnet/02-service.yaml
