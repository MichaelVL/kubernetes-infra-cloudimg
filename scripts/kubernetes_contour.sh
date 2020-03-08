#!/bin/bash

set -eux

echo "--> Pulling Contour"
mkdir -p /etc/kubernetes/addon-manifests/contour
cd /etc/kubernetes/addon-manifests/contour
curl -sO https://raw.githubusercontent.com/projectcontour/contour/release-1.2/examples/contour/00-common.yaml
curl -sO https://raw.githubusercontent.com/projectcontour/contour/release-1.2/examples/contour/01-contour-config.yaml
curl -sO https://raw.githubusercontent.com/projectcontour/contour/release-1.2/examples/contour/01-crds.yaml
curl -sO https://raw.githubusercontent.com/projectcontour/contour/release-1.2/examples/contour/02-job-certgen.yaml
curl -sO https://raw.githubusercontent.com/projectcontour/contour/release-1.2/examples/contour/02-rbac.yaml
curl -sO https://raw.githubusercontent.com/projectcontour/contour/release-1.2/examples/contour/02-service-contour.yaml
curl -sO https://raw.githubusercontent.com/projectcontour/contour/release-1.2/examples/contour/02-service-envoy.yaml
curl -sO https://raw.githubusercontent.com/projectcontour/contour/release-1.2/examples/contour/03-contour.yaml
curl -sO https://raw.githubusercontent.com/projectcontour/contour/release-1.2/examples/contour/03-envoy.yaml

# Dashboard
curl -sO https://raw.githubusercontent.com/projectcontour/contour/release-1.2/examples/grafana/01-namespace.yaml
curl -sO https://raw.githubusercontent.com/projectcontour/contour/release-1.2/examples/grafana/02-grafana-configmap.yaml

crictl pull docker.io/projectcontour/contour:v1.2.1
# Bug in 1.2
crictl pull docker.io/projectcontour/contour:latest
crictl pull docker.io/envoyproxy/envoy:v1.13.1
