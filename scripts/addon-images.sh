#!/bin/bash

set -eux

echo "--> Pulling a selection of Docker base images"
crictl pull docker.io/calico/cni:v3.13.5
crictl pull docker.io/calico/kube-controllers:v3.13.5
crictl pull docker.io/calico/node:v3.13.5
crictl pull docker.io/calico/pod2daemon-flexvol:v3.13.5
crictl pull docker.io/directxman12/k8s-prometheus-adapter-amd64:v0.6.0
crictl pull docker.io/envoyproxy/envoy:v1.14.1
crictl pull docker.io/grafana/grafana:6.7.1
crictl pull docker.io/grafana/loki:1.4.1
crictl pull docker.io/grafana/promtail:1.4.1
crictl pull docker.io/istio/operator:1.7.5
crictl pull docker.io/istio/pilot:1.7.5
crictl pull docker.io/istio/proxyv2:1.7.5
crictl pull docker.io/jaegertracing/all-in-one:1.18
crictl pull docker.io/jimmidyson/configmap-reload:v0.3.0
crictl pull docker.io/kiwigrid/k8s-sidecar:0.1.99
crictl pull docker.io/library/nginx:1.9.1
crictl pull docker.io/metallb/controller:v0.8.1
crictl pull docker.io/metallb/speaker:v0.8.1
crictl pull docker.io/michaelvl/sentences:v1
crictl pull docker.io/projectcontour/contour:latest
crictl pull docker.io/projectcontour/contour:v1.4.0
crictl pull docker.io/prom/alertmanager:v0.20.0
crictl pull docker.io/prom/node-exporter:v0.18.1
crictl pull docker.io/prom/prometheus:v2.16.0
crictl pull docker.io/prom/prometheus:v2.19.2
crictl pull k8s.gcr.io/coredns:1.7.0
crictl pull k8s.gcr.io/etcd:3.4.13-0
crictl pull k8s.gcr.io/kube-apiserver:v1.19.4
crictl pull k8s.gcr.io/kube-controller-manager:v1.19.4
crictl pull k8s.gcr.io/kube-proxy:v1.19.4
crictl pull k8s.gcr.io/kube-scheduler:v1.19.4
crictl pull k8s.gcr.io/metrics-server-amd64:v0.3.6
crictl pull k8s.gcr.io/pause:3.1
crictl pull k8s.gcr.io/pause:3.2
crictl pull quay.io/bitnami/sealed-secrets-controller:v0.12.1
crictl pull quay.io/coreos/kube-state-metrics:v1.9.5
crictl pull quay.io/jetstack/cert-manager-cainjector:v0.14.1
crictl pull quay.io/jetstack/cert-manager-controller:v0.14.1
crictl pull quay.io/jetstack/cert-manager-webhook:v0.14.1
crictl pull quay.io/kiali/kiali:v1.22
crictl pull quay.io/kubernetes_incubator/nfs-provisioner:v2.3.0

echo "--> Images available after installing additional images"
crictl images

echo "--> Disk space available"
df
