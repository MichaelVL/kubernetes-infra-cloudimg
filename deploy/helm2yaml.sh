#! /bin/bash

HELM2YAML_IMAGE='michaelvl/helm2yaml'
KUBEAUDIT_IMAGE='michaelvl/kubeaudit:0.7.0'

set -xe

filename=$1
render_to=$2
basename=$(basename -- "$filename")
appname="${basename%.*}"

mkdir -p "$render_to"

# Map current folder as /src and assume all files passed with -f are relative to this
# Env HOME setting is necessary because Helm3 use HOME for config files
docker run --rm --user $(id -u):$(id -g) -e HOME=/tmp/home -v $(pwd):/src:ro -v $(pwd)/${render_to}:/rendered:rw $HELM2YAML_IMAGE --api-versions apiregistration.k8s.io/v1beta1 --api-versions apiextensions.k8s.io/v1beta1 --auto-api-upgrade --render-to /rendered/${appname}.yaml --render-namespace-to /rendered/${appname}-ns.yaml --hook-filter '' helmsman -f ${filename}

# Build audit report
MANIFESTS="-v $(pwd)/${render_to}:/work"
docker run --user $(id -u):$(id -g) --rm $MANIFESTS:ro ${KUBEAUDIT_IMAGE} all -f ${appname}.yaml -f ${appname}-ns.yaml 2> $render_to/${appname}-audit.txt

echo "Audit report:"
cat $render_to/${appname}-audit.txt