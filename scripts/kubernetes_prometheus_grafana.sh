#!/bin/bash -eux

echo "--> Fetching Prometheus and Grafana images"

# https://github.com/kubernetes/charts/tree/master/stable/prometheus
# Helm chart cersion 6.7.2
docker pull prom/alertmanager:v0.14.0
docker pull jimmidyson/configmap-reload:v0.1
docker pull gcr.io/google_containers/kube-state-metrics:v1.3.1
docker pull prom/node-exporter:v0.15.2
docker pull prom/prometheus:v2.2.1
docker pull prom/pushgateway:v0.5.1

# https://github.com/kubernetes/charts/tree/master/stable/grafana
# Helm chart version 1.11.1
docker pull grafana/grafana:5.1.3
docker pull appropriate/curl:latest
docker pull kiwigrid/k8s-sidecar:0.0.3
