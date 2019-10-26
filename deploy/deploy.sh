#!/bin/bash

# This script deploys non-Helm components

set -ex

function deploy_flannel {
    export KUBECONFIG=/etc/kubernetes/admin.conf
    kubectl apply -f /etc/kubernetes/addon-manifests/flannel/kube-flannel.yml
}

function deploy_canal {
    export KUBECONFIG=/etc/kubernetes/admin.conf
    cd /etc/kubernetes/addon-manifests/canal/
    sed -i -e "s?10.244.0.0/16?$POD_CIDR?g" canal.yaml
    kubectl apply -f canal.yaml
}

function deploy_calico {
    export KUBECONFIG=/etc/kubernetes/admin.conf
    cd /etc/kubernetes/addon-manifests/calico/
    cp calico.yaml calico-orig.yaml
    sed -i -e 's/192.168.0.0/10.244.0.0/' calico.yaml
    kubectl apply -f calico.yaml
}

function deploy_weave {
    export KUBECONFIG=/etc/kubernetes/admin.conf
    kubectl apply -n kube-system -f /etc/kubernetes/addon-manifests/weave-net
}

function deploy_rook_ceph_storage_provider {
    export KUBECONFIG=/etc/kubernetes/admin.conf
    # https://github.com/rook/rook/issues/2380
    NODES=$(kubectl get nodes -o jsonpath="{.items[*].metadata.name}")
    FMT="    nodes:"
    for node in ${NODES[*]}
    do
      FMT="$FMT\n    - name: \"$node\""
    done
    sed -i -e "s|    useAllNodes: true|$FMT|" /etc/kubernetes/addon-manifests/rook-ceph-storage-provisioner/cluster.yaml

    kubectl create -f /etc/kubernetes/addon-manifests/rook-ceph-storage-provisioner/common.yaml
    kubectl create -f /etc/kubernetes/addon-manifests/rook-ceph-storage-provisioner/operator.yaml
    kubectl create -f /etc/kubernetes/addon-manifests/rook-ceph-storage-provisioner/cluster.yaml
    kubectl create -f /etc/kubernetes/addon-manifests/rook-ceph-storage-provisioner/storageclass.yaml
    kubectl annotate storageclass rook-ceph-block storageclass.beta.kubernetes.io/is-default-class=true
}

function deploy_cert_manager_crd {
    export KUBECONFIG=/etc/kubernetes/admin.conf
    kubectl create -f /etc/kubernetes/addon-manifests/cert-manager/00-crds.yaml
    kubectl create namespace cert-manager
    kubectl label namespace cert-manager certmanager.k8s.io/disable-validation="true"
}

function deploy_vertical_pod_autoscaler {
    export KUBECONFIG=/etc/kubernetes/admin.conf
    cd /etc/kubernetes/addon-manifests/vpa/autoscaler/vertical-pod-autoscaler
    ./hack/vpa-up.sh
}

function deploy_contour {
    export KUBECONFIG=/etc/kubernetes/admin.conf
    kubectl apply -f /etc/kubernetes/addon-manifests/contour
    kubectl -n contour-monitoring label cm grafana-dashs grafana_dashboard=1
}

while [[ $# -gt 0 ]]
do
  key="$1"
  case $key in
    --flannel)
	deploy_flannel
	;;
    --canal)
	deploy_canal
	;;
    --calico)
	deploy_calico
	;;
    --weave)
	deploy_weave
	;;
    --rook-ceph-provisioner)
	deploy_rook_ceph_storage_provider
	;;
    --cert-manager-crd)
	deploy_cert_manager_crd
	;;
    --vpa)
	deploy_vertical_pod_autoscaler
	;;
    --contour)
	deploy_contour
	;;
  esac
  shift
done
