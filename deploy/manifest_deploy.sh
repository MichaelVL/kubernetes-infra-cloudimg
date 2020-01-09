#! /bin/bash

HELM2YAML_IMAGE='michaelvl/helm2yaml'
KUBECTL_IMAGE='bitnami/kubectl:1.16.3'

set -x
set -e

base_path=$1
basename=$2
env_vars=${3:-""}

manifest_path=$base_path/${basename}.yaml
namespace_path=$base_path/${basename}-ns.yaml
manifest_w_explicit_ns_path=$base_path/${basename}-w-ns.yaml
secrets_path=$base_path/${basename}-secrets.yaml
secrets_w_explicit_ns_path=$base_path/${basename}-secrets-w-ns.yaml

env_set=""
for e in $env_vars; do
    env_set="-e $e $env_set"
done

# Pass-in both the user .kube folder and the current value of KUBECONFIG
KUBECFG="-v ${HOME}/.kube:${HOME}/.kube"
MANIFESTS="-v $(pwd):/work"
KUBECTL_CMD="docker run -i --user $(id -u):$(id -g) --net host --rm -e KUBECONFIG $KUBECFG:ro -w /work $MANIFESTS:ro ${KUBECTL_IMAGE}"

if [ ! -z $namespace_path ] && [ -f $namespace_path ]; then
    $KUBECTL_CMD apply -f $namespace_path
    NS=$(yq -r '.metadata.name' $namespace_path)
    if [ ! -z $secrets_path ] && [ -f $secrets_path ]; then
        cat $secrets_path | docker run --rm -i --entrypoint /bin/k8envsubst.py $env_set $HELM2YAML_IMAGE | $KUBECTL_CMD -n $NS apply -f -
    fi
fi

if [ ! -z $secrets_w_explicit_ns_path ] && [ -f $secrets_w_explicit_ns_path ]; then
    cat $secrets_w_explicit_ns_path | docker run --rm -i --entrypoint /bin/k8envsubst.py $env_set $HELM2YAML_IMAGE | $KUBECTL_CMD apply -f -
fi

if [ ! -z $namespace_path ] && [ -f $namespace_path ]; then
    if [ ! -z $manifest_path ] && [ -f $manifest_path ]; then
        cat $manifest_path | docker run --rm -i --entrypoint /bin/k8envsubst.py $env_set $HELM2YAML_IMAGE | $KUBECTL_CMD -n $NS apply -f -
    fi
fi

if [ ! -z $manifest_w_explicit_ns_path ] && [ -f $manifest_w_explicit_ns_path ]; then
    cat $manifest_w_explicit_ns_path | docker run --rm -i --entrypoint /bin/k8envsubst.py $env_set $HELM2YAML_IMAGE | $KUBECTL_CMD apply -f -
fi
