#!/bin/bash

set -eux

source scripts/context-variables.sh

echo "$1 gcr.io/kubernetes-helm/tiller:$HELM_VERSION"

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

echo "# ${HELM_METALLB_CHART} ${HELM_METALLB_VERSION}"
HELM_VALUES=$(helm inspect values ${HELM_METALLB_CHART} --version ${HELM_METALLB_VERSION} |yq .)
for component in controller speaker; do
    IMAGE=`echo ${HELM_VALUES}|jq -r ".${component}.image | [.repository, .tag] | join(\":\")"`
    echo "$1 ${IMAGE}"
done

echo "# ${HELM_METRICS_SERVER_CHART} ${HELM_METRICS_SERVER_VERSION}"
HELM_VALUES=$(helm inspect values ${HELM_METRICS_SERVER_CHART} --version ${HELM_METRICS_SERVER_VERSION} |yq .)
IMAGE=`echo ${HELM_VALUES}|jq -r "[.image.repository, .image.tag] | join(\":\")"`
echo "$1 ${IMAGE}"

echo "# ${HELM_CERT_MANAGER_CHART} ${HELM_CERT_MANAGER_VERSION}"
HELM_VALUES=$(helm inspect values ${HELM_CERT_MANAGER_CHART} --version ${HELM_CERT_MANAGER_VERSION} |yq .)
#IMAGE=`echo ${HELM_VALUES}|jq -r "[.image.repository, .image.tag] | join(\":\")"`
IMAGE=`echo ${HELM_VALUES}|jq -r ".image.repository"`
echo "$1 ${IMAGE}:${HELM_CERT_MANAGER_VERSION}"

echo "# ${HELM_CONTOUR_CHART} ${HELM_CONTOUR_VERSION} ${HELM_CONTOUR_URL}"
HELM_VALUES=$(helm inspect values ${HELM_CONTOUR_CHART} --repo ${HELM_CONTOUR_URL} --version ${HELM_CONTOUR_VERSION} |yq .)
for component in contour envoy; do
    IMAGE=`echo ${HELM_VALUES}|jq -r ".${component}.image | [.repository, .tag] | join(\":\")"`
    echo "$1 ${IMAGE}"
done
