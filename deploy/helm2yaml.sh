#! /bin/bash

HELM2YAML_IMAGE='michaelvl/helm2yaml'

#set -xe

filename=$1
render_to=$2
env_vars=${3:-""}

basename=$(basename -- "$filename")
appname="${basename%.*}"

env_set=""
for e in $env_vars; do
    env_set="-e $e $env_set"
done

mkdir -p "$render_to"

# Map current folder as /src and assume all files passed with -f are relative to this
# Env HOME setting is necessary because Helm3 use HOME for config files
docker run --rm --user $(id -u):$(id -g) -e HOME=/tmp/home $env_set \
       -v $(pwd):/src:ro -v $(pwd)/${render_to}:/rendered:rw $HELM2YAML_IMAGE \
       --api-versions apiregistration.k8s.io/v1beta1 --api-versions apiextensions.k8s.io/v1beta1 \
       --auto-api-upgrade \
       --render-to /rendered/${appname}.yaml \
       --render-w-ns-to /rendered/${appname}-w-ns.yaml \
       --render-secrets-to /rendered/${appname}-secrets.yaml \
       --render-secrets-w-ns-to /rendered/${appname}-secrets-w-ns.yaml \
       --render-namespace-to /rendered/${appname}-ns.yaml \
       --hook-filter '' helmsman -f ${filename}

./deploy/kubeaudit.sh all -f $render_to/${appname}.yaml -f $render_to/${appname}-w-ns.yaml -f $render_to/${appname}-ns.yaml 2> $render_to/${appname}-audit.txt
