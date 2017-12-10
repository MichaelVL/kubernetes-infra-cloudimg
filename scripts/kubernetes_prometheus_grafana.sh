#!/bin/bash -eux

echo "--> Fetching Prometheus and Grafana images"

# https://github.com/kubernetes/charts/tree/master/stable/prometheus
docker pull prom/alertmanager:v0.9.1
docker pull jimmidyson/configmap-reload:v0.1
docker pull gcr.io/google_containers/kube-state-metrics:v1.1.0-rc.0
docker pull prom/node-exporter:v0.15.0
docker pull prom/prometheus:v1.8.1
docker pull prom/pushgateway:v0.4.0

# https://github.com/kubernetes/charts/tree/master/stable/grafana
# https://hub.docker.com/r/grafana/grafana/tags/
docker pull grafana/grafana:4.6.2
