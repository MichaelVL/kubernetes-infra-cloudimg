#!/bin/bash

set -eux

HELM2YAML='michaelvl/helm2yaml:latest'
CHARTS='deploy/prometheus.yaml deploy/prometheus-adapter.yaml deploy/grafana.yaml deploy/loki.yaml deploy/promtail.yaml deploy/metallb.yaml deploy/metrics-server.yaml deploy/cert-manager.yaml deploy/nfs-server-storage-provisioner.yaml deploy/sealed-secrets.yaml'

for chart in $CHARTS; do
    for img in $(docker run --rm -v $(pwd):/src:ro $HELM2YAML --list-images helmsman -f $chart); do
        echo "$1 $img"
    done
done
