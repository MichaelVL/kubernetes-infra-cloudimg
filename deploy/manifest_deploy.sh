#! /bin/bash

HELM2YAML_IMAGE='michaelvl/helm2yaml'
KUBECTL_IMAGE='bitnami/kubectl:1.15.0'

set -xe

manifest_path=$1
namespace_path=$2
manifest_w_explicit_ns_path=$3

# Pass-in both the user .kube folder and the current value of KUBECONFIG
KUBECFG="-v ${HOME}/.kube:${HOME}/.kube"
MANIFESTS="-v $(pwd):/work"
KUBECTL_CMD="docker run -i --user $(id -u):$(id -g) --rm -e KUBECONFIG $KUBECFG:ro -w /work $MANIFESTS:ro ${KUBECTL_IMAGE}"

if [ ! -z $namespace_path ] && [ -f $namespace_path ]; then
    $KUBECTL_CMD apply -f $namespace_path
    NS=$(yq -r '.metadata.name' $namespace_path)
    if [ ! -z $manifest_path ] && [ -f $manifest_path ]; then
        # The environment variables shown here are usefull for deployment of e.g. https://github.com/MichaelVL/kubernetes-infra-cloudimg
        cat $manifest_path | docker run --rm -i --entrypoint /bin/k8envsubst.py -e GRAFANA_ADMIN_PASSWD -e DNS_DOMAIN -e NFS_STORAGE_PROVISIONER_HOSTNAME $HELM2YAML_IMAGE | $KUBECTL_CMD -n $NS apply -f -
    fi
fi

if [ ! -z $manifest_w_explicit_ns_path ] && [ -f $manifest_w_explicit_ns_path ]; then
    # The environment variables shown here are usefull for deployment of e.g. https://github.com/MichaelVL/kubernetes-infra-cloudimg
    cat $manifest_w_explicit_ns_path | docker run --rm -i --entrypoint /bin/k8envsubst.py -e GRAFANA_ADMIN_PASSWD -e DNS_DOMAIN -e NFS_STORAGE_PROVISIONER_HOSTNAME $HELM2YAML_IMAGE | $KUBECTL_CMD apply -f -
fi
