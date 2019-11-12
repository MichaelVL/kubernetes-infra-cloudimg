#!/bin/bash

set -eux

HELM2YAML='michaelvl/helm2yaml:latest'
APIVERSIONS='--api-versions apiregistration.k8s.io/v1beta1 --api-versions apiextensions.k8s.io/v1beta1'
CHARTS='deploy/prometheus.yaml deploy/prometheus-adapter.yaml deploy/grafana.yaml deploy/loki.yaml deploy/metallb.yaml deploy/metrics-server.yaml deploy/cert-manager.yaml deploy/nfs-storage-provisioner.yaml'

for chart in $CHARTS; do
    for img in $(docker run --rm -v $(pwd):/src:ro $HELM2YAML $APIVERSIONS --list-images helmsman -f $chart); do
        echo "$1 $img"
    done
done
