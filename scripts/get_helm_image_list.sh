#!/bin/bash

set -eux

HELM_VERSION='v2.15.1'

HELM2YAML='michaelvl/helm2yaml:latest'
APIVERSIONS='--api-versions apiregistration.k8s.io/v1beta1 --api-versions apiextensions.k8s.io/v1beta1'
CHARTS='deploy/prometheus.yaml deploy/prometheus-adapter.yaml deploy/grafana.yaml deploy/loki.yaml deploy/metallb.yaml deploy/metrics-server.yaml deploy/cert-manager.yaml deploy/nfs-storage-provisioner.yaml'

echo "$1 gcr.io/kubernetes-helm/tiller:$HELM_VERSION"

for chart in $CHARTS; do
    for img in $(docker run --rm -v $(pwd):/src:ro $HELM2YAML $APIVERSIONS --list-images helmsman -f $chart); do
        echo "$1 $img"
    done
done
