#!/bin/bash

set -eux

apt-get install -y xfsprogs lvm2

echo "--> Fetching VPA manifests"
mkdir -p /etc/kubernetes/addon-manifests/vpa
cd /etc/kubernetes/addon-manifests/vpa

git clone https://github.com/kubernetes/autoscaler.git
rm -rf addon-resizer cluster-autoscaler builder

IMAGE=$(grep 'image\:' vertical-pod-autoscaler/deploy/admission-controller-deployment.yaml | cut -d':' -f3)
echo "--> Pulling VPA controller image ($IMAGE)"
crictl pull $IMAGE

IMAGE=$(grep 'image\:' vertical-pod-autoscaler/deploy/recommender-deployment.yaml | cut -d':' -f3)
echo "--> Pulling VPA recommender image ($IMAGE)"
crictl pull $IMAGE

IMAGE=$(grep 'image\:' vertical-pod-autoscaler/deploy/updater-deployment.yaml | cut -d':' -f3)
echo "--> Pulling VPA updater image ($IMAGE)"
crictl pull $IMAGE
