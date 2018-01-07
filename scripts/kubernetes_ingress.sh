#!/bin/bash -eux

# https://github.com/kubernetes/charts/tree/master/stable/nginx-ingress

docker pull gcr.io/google_containers/nginx-ingress-controller:0.9.0-beta.15
docker pull gcr.io/google_containers/defaultbackend:1.4

# https://github.com/kubernetes/charts/tree/master/stable/kube-lego

docker pull jetstack/kube-lego:0.1.5
