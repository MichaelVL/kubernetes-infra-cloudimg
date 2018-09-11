#!/bin/bash

set -eux

# https://github.com/kubernetes/charts/tree/master/stable/nginx-ingress

docker pull gcr.io/google_containers/nginx-ingress-controller:0.9.0-beta.15
docker pull gcr.io/google_containers/defaultbackend:1.4

# Cert manager deprecates kube-lego
docker pull quay.io/jetstack/cert-manager-controller:v0.2.3
docker pull quay.io/jetstack/cert-manager-ingress-shim:v0.2.3
