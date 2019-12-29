#!/bin/bash

set -eux

echo "--> Pulling ArgoCD images"

crictl pull docker.io/argoproj/argocd:v1.3.6
crictl pull quay.io/dexidp/dex:v2.14.0
crictl pull docker.io/redis:5.0.3
