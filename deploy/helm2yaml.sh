#! /bin/bash

HELM2YAML_IMAGE='michaelvl/helm2yaml'
KUBESEAL_IMAGE='michaelvl/kubeseal:v0.9.6'

#set -x
set -e

filename=$1
render_to=$2
env_vars=${3:-""}
kubeseal_cert=sealed-secrets-pub-cert.pem

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
       --render-path /rendered \
       --separate-with-namespace \
       --separate-secrets \
       --hook-filter '' helmsman -f ${filename}

./deploy/kubeaudit.sh all -f $render_to/${appname}.yaml -f $render_to/${appname}-w-ns.yaml -f $render_to/${appname}-ns.yaml 2> $render_to/${appname}-audit.txt

secrets_path=${render_to}/${appname}-secrets.yaml
secrets_w_explicit_ns_path=$render_to/${appname}-secrets-w-ns.yaml

if [ ! -z $secrets_path ] && [ -f $secrets_path ]; then
    cp $secrets_path "$secrets_path.bck"
    cat "$secrets_path.bck" | docker run -i --rm --user $(id -u):$(id -g) -v $(pwd):/work:rw $KUBESEAL_IMAGE --cert $kubeseal_cert > $secrets_path
    rm  "$secrets_path.bck"
fi
if [ ! -z $secrets_w_explicit_ns_path ] && [ -f $secrets_w_explicit_ns_path ]; then
    cp $secrets_w_explicit_ns_path "$secrets_w_explicit_ns_path.bck"
    cat "$secrets_w_explicit_ns_path.bck" | docker run -i --rm --user $(id -u):$(id -g) -v $(pwd):/work:rw $KUBESEAL_IMAGE --cert $kubeseal_cert > $secrets_w_explicit_ns_path
    rm "$secrets_w_explicit_ns_path.bck"
fi
