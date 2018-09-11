#!/bin/bash

set -eux

source scripts/context-variables.sh

echo "# ${HELM_PROMETHEUS_CHART} ${HELM_PROMETHEUS_VERSION}"
HELM_VALUES=$(helm inspect values ${HELM_PROMETHEUS_CHART} --version ${HELM_PROMETHEUS_VERSION} |yq .)
for component in alertmanager configmapReload initChownData kubeStateMetrics nodeExporter server pushgateway; do
    IMAGE=`echo ${HELM_VALUES}|jq -r ".${component}.image | [.repository, .tag] | join(\":\")"`
    echo "$1 ${IMAGE}"
done

echo "# ${HELM_GRAFANA_CHART} ${HELM_GRAFANA_VERSION}"
HELM_VALUES=$(helm inspect values ${HELM_GRAFANA_CHART} --version ${HELM_GRAFANA_VERSION} |yq .)
for component in image downloadDashboardsImage; do
    IMAGE=`echo ${HELM_VALUES}|jq -r ".${component} | [.repository, .tag] | join(\":\")"`
    echo "$1 ${IMAGE}"
done
IMAGE=`echo ${HELM_VALUES}|jq -r ".sidecar.image"`
echo "$1 ${IMAGE}"
