#!/bin/bash -eux

echo "--> Fetching Prometheus and Grafana images"

# https://github.com/kubernetes/charts/tree/master/stable/prometheus
docker pull prom/alertmanager:v0.9.1
docker pull jimmidyson/configmap-reload:v0.1
docker pull gcr.io/google_containers/kube-state-metrics:v1.1.0
docker pull prom/node-exporter:v0.15.2
docker pull prom/prometheus:v2.1.0
docker pull prom/pushgateway:v0.4.0
docker pull appropriate/curl:latest

# https://github.com/kubernetes/charts/tree/master/stable/grafana
# https://hub.docker.com/r/grafana/grafana/tags/
docker pull grafana/grafana:4.6.3
