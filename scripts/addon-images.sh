#!/bin/bash

set -eux

echo "--> Pulling a selection of Docker base images"
crictl pull docker.io/argoproj/argocd:v1.3.6
crictl pull docker.io/bats/bats:v1.1.0
crictl pull docker.io/bitnami/mongodb:3.7.1-r0
crictl pull docker.io/bitnami/mongodb:4.0.6
crictl pull docker.io/bitnami/rabbitmq:3.7.11
crictl pull docker.io/bitnami/rabbitmq:3.7.2-r1
crictl pull docker.io/calico/cni:v3.13.2
crictl pull docker.io/calico/cni:v3.8.8-1
crictl pull docker.io/calico/kube-controllers:v3.13.2
crictl pull docker.io/calico/node:v3.13.2
crictl pull docker.io/calico/node:v3.8.8-1
crictl pull docker.io/calico/pod2daemon-flexvol:v3.13.2
crictl pull docker.io/calico/pod2daemon-flexvol:v3.8.8
crictl pull docker.io/ceph/ceph:v14.2.8
crictl pull docker.io/ceph/ceph:v14.2.9
crictl pull docker.io/directxman12/k8s-prometheus-adapter-amd64:v0.6.0
crictl pull docker.io/envoyproxy/envoy:v1.13.1
crictl pull docker.io/grafana/grafana:6.6.2
crictl pull docker.io/grafana/grafana:6.7.1
crictl pull docker.io/grafana/loki:1.4.1
crictl pull docker.io/grafana/loki:v1.2.0
crictl pull docker.io/grafana/loki:v1.3.0
crictl pull docker.io/grafana/promtail:1.4.1
crictl pull docker.io/grafana/promtail:v1.3.0
crictl pull docker.io/jimmidyson/configmap-reload:v0.3.0
crictl pull docker.io/kiwigrid/k8s-sidecar:0.1.99
crictl pull docker.io/library/busybox:latest
crictl pull docker.io/library/nginx:1.15.3-alpine
crictl pull docker.io/library/nginx:1.17.9
crictl pull docker.io/library/nginx:latest
crictl pull docker.io/library/python:2-slim
crictl pull docker.io/library/redis:5.0.3
crictl pull docker.io/metallb/controller:v0.8.1
crictl pull docker.io/metallb/speaker:v0.8.1
crictl pull docker.io/michaelvl/osmtracker:git-11ec442
crictl pull docker.io/projectcontour/contour:latest
crictl pull docker.io/projectcontour/contour:v1.2.1
crictl pull docker.io/prom/alertmanager:v0.20.0
crictl pull docker.io/prom/node-exporter:v0.18.1
crictl pull docker.io/prom/prometheus:v2.16.0
crictl pull docker.io/rook/ceph:master
crictl pull docker.io/weaveworks/weave-kube:2.6.2
crictl pull docker.io/weaveworks/weave-npc:2.6.2
crictl pull gcr.io/google_containers/metrics-server-amd64:v0.3.6
crictl pull k8s.gcr.io/coredns:1.6.7
crictl pull k8s.gcr.io/etcd:3.4.3-0
crictl pull k8s.gcr.io/kube-apiserver:v1.18.2
crictl pull k8s.gcr.io/kube-controller-manager:v1.18.2
crictl pull k8s.gcr.io/kube-proxy:v1.18.2
crictl pull k8s.gcr.io/kube-scheduler:v1.18.2
crictl pull k8s.gcr.io/metrics-server-amd64:v0.3.6
crictl pull k8s.gcr.io/pause:3.1
crictl pull k8s.gcr.io/pause:3.2
crictl pull k8s.gcr.io/vpa-admission-controller:0.6.3
crictl pull k8s.gcr.io/vpa-recommender:0.6.3
crictl pull k8s.gcr.io/vpa-updater:0.6.3
crictl pull quay.io/bitnami/sealed-secrets-controller:v0.10.0
crictl pull quay.io/bitnami/sealed-secrets-controller:v0.12.1
crictl pull quay.io/coreos/flannel:v0.11.0
crictl pull quay.io/coreos/flannel:v0.12.0-amd64
crictl pull quay.io/coreos/kube-state-metrics:v1.9.5
crictl pull quay.io/dexidp/dex:v2.14.0
crictl pull quay.io/jetstack/cert-manager-acmesolver:v0.14.1
crictl pull quay.io/jetstack/cert-manager-cainjector:v0.14.1
crictl pull quay.io/jetstack/cert-manager-controller:v0.14.1
crictl pull quay.io/jetstack/cert-manager-webhook:v0.14.1
crictl pull quay.io/kubernetes_incubator/nfs-provisioner:v2.3.0
crictl pull quay.io/open-policy-agent/gatekeeper:v3.1.0-beta.7
crictl pull quay.io/pusher/oauth2_proxy:v5.1.0
crictl pull us.gcr.io/k8s-artifacts-prod/autoscaling/vpa-admission-controller:0.8.0
crictl pull us.gcr.io/k8s-artifacts-prod/autoscaling/vpa-recommender:0.8.0
crictl pull us.gcr.io/k8s-artifacts-prod/autoscaling/vpa-updater:0.8.0

echo "--> Images available after installing additional images"
crictl images
