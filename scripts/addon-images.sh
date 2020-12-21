#!/bin/bash

set -eux

echo "--> Pulling a selection of Docker base images"
crictl pull docker.io/argoproj/argocd:v1.8.1
crictl pull docker.io/calico/cni:v3.13.5
crictl pull docker.io/calico/cni:v3.8.9
crictl pull docker.io/calico/kube-controllers:v3.13.5
crictl pull docker.io/calico/node:v3.13.5
crictl pull docker.io/calico/node:v3.8.9
crictl pull docker.io/calico/pod2daemon-flexvol:v3.13.5
crictl pull docker.io/calico/pod2daemon-flexvol:v3.8.9
crictl pull docker.io/ceph/ceph:v15.2.8
crictl pull docker.io/directxman12/k8s-prometheus-adapter-amd64:v0.6.0
crictl pull docker.io/envoyproxy/envoy:v1.14.1
crictl pull docker.io/grafana/grafana:7.3.5
crictl pull docker.io/grafana/loki:1.4.1
crictl pull docker.io/grafana/promtail:1.4.1
crictl pull docker.io/jimmidyson/configmap-reload:v0.4.0
crictl pull docker.io/kiwigrid/k8s-sidecar:1.1.0
crictl pull docker.io/library/nginx:1.9.1
crictl pull docker.io/library/redis:5.0.10-alpine
crictl pull docker.io/metallb/controller:v0.8.1
crictl pull docker.io/metallb/speaker:v0.8.1
crictl pull docker.io/michaelvl/sentences:v1
crictl pull docker.io/projectcontour/contour:latest
crictl pull docker.io/projectcontour/contour:v1.4.0
crictl pull docker.io/rook/ceph:master
crictl pull docker.io/weaveworks/weave-kube:2.7.0
crictl pull docker.io/weaveworks/weave-npc:2.7.0
crictl pull k8s.gcr.io/autoscaling/vpa-admission-controller:0.9.0
crictl pull k8s.gcr.io/autoscaling/vpa-recommender:0.9.0
crictl pull k8s.gcr.io/autoscaling/vpa-updater:0.9.0
crictl pull k8s.gcr.io/coredns:1.7.0
crictl pull k8s.gcr.io/etcd:3.4.13-0
crictl pull k8s.gcr.io/kube-apiserver:v1.20.1
crictl pull k8s.gcr.io/kube-controller-manager:v1.20.1
crictl pull k8s.gcr.io/kube-proxy:v1.20.1
crictl pull k8s.gcr.io/kube-scheduler:v1.20.1
crictl pull k8s.gcr.io/metrics-server-amd64:v0.3.6
crictl pull k8s.gcr.io/pause:3.1
crictl pull k8s.gcr.io/pause:3.2
crictl pull quay.io/bitnami/sealed-secrets-controller:v0.13.1
crictl pull quay.io/coreos/flannel:v0.11.0
crictl pull quay.io/coreos/flannel:v0.12.0-amd64
crictl pull quay.io/coreos/kube-state-metrics:v1.9.7
crictl pull quay.io/dexidp/dex:v2.25.0
crictl pull quay.io/jetstack/cert-manager-cainjector:v0.14.1
crictl pull quay.io/jetstack/cert-manager-controller:v0.14.1
crictl pull quay.io/jetstack/cert-manager-webhook:v0.14.1
crictl pull quay.io/kubernetes_incubator/nfs-provisioner:v2.3.0
crictl pull quay.io/prometheus/alertmanager:v0.21.0
crictl pull quay.io/prometheus/node-exporter:v1.0.1
crictl pull quay.io/prometheus/prometheus:v2.22.1

crictl pull docker.io/michaelvl/sentences:v1

echo "--> Images available after installing additional images"
crictl images

echo "--> Disk space available"
df
