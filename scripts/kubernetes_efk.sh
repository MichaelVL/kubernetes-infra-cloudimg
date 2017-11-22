#!/bin/bash -eux

# https://github.com/kubernetes/kubernetes/tree/master/cluster/addons/fluentd-elasticsearch
echo "--> Fetching Elasticsearch, Fluentd and Kibana manifests"
mkdir -p /etc/kubernetes/addon-manifests/efk
cd /etc/kubernetes/addon-manifests/efk
curl -sO https://raw.githubusercontent.com/kubernetes/kubernetes/master/cluster/addons/fluentd-elasticsearch/es-service.yaml
curl -sO https://raw.githubusercontent.com/kubernetes/kubernetes/master/cluster/addons/fluentd-elasticsearch/es-statefulset.yaml
curl -sO https://raw.githubusercontent.com/kubernetes/kubernetes/master/cluster/addons/fluentd-elasticsearch/fluentd-es-configmap.yaml
curl -sO https://raw.githubusercontent.com/kubernetes/kubernetes/master/cluster/addons/fluentd-elasticsearch/fluentd-es-ds.yaml
curl -sO https://raw.githubusercontent.com/kubernetes/kubernetes/master/cluster/addons/fluentd-elasticsearch/kibana-deployment.yaml
curl -sO https://raw.githubusercontent.com/kubernetes/kubernetes/master/cluster/addons/fluentd-elasticsearch/kibana-service.yaml

docker pull gcr.io/google-containers/elasticsearch:v5.6.2
docker pull gcr.io/google-containers/fluentd-elasticsearch:v2.0.2
docker pull docker.elastic.co/kibana/kibana:5.6.2
