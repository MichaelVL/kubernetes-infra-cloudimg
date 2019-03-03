#!/bin/bash

# This script deploys non-Helm components

set -ex

function deploy_flannel {
    export KUBECONFIG=/etc/kubernetes/admin.conf
    kubectl apply -f /etc/kubernetes/addon-manifests/flannel/kube-flannel.yml
}

function deploy_canal {
    export KUBECONFIG=/etc/kubernetes/admin.conf
    kubectl apply -f /etc/kubernetes/addon-manifests/canal/rbac.yaml
    kubectl apply -f /etc/kubernetes/addon-manifests/canal/canal.yaml
}

function deploy_calico {
    export KUBECONFIG=/etc/kubernetes/admin.conf
    cp /etc/kubernetes/addon-manifests/calico/calico.yaml /etc/kubernetes/addon-manifests/calico/calico-orig.yaml
    sed -i -e 's/192.168.0.0/10.244.0.0/' /etc/kubernetes/addon-manifests/calico/calico.yaml
    kubectl apply -f /etc/kubernetes/addon-manifests/calico/rbac-kdd.yaml
    kubectl apply -f /etc/kubernetes/addon-manifests/calico/calico.yaml
}

function deploy_weave {
    export KUBECONFIG=/etc/kubernetes/admin.conf
    kubectl apply -n kube-system -f /etc/kubernetes/addon-manifests/weave-net
}

function deploy_dashboard {
    export KUBECONFIG=/etc/kubernetes/admin.conf
    kubectl apply -n kube-system -f /etc/kubernetes/addon-manifests/dashboard
}

function deploy_nfs_storage_provider {
    export KUBECONFIG=/etc/kubernetes/admin.conf
    export NAMESPACE=default
    #export NAMESPACE=nfs-storage
    #kubectl create ns $NAMESPACE
    kubectl create -n  $NAMESPACE -f /etc/kubernetes/addon-manifests/nfs-storage-provisioner/rbac.yaml
    kubectl create -n  $NAMESPACE -f /etc/kubernetes/addon-manifests/nfs-storage-provisioner/psp.yaml
    kubectl create -n  $NAMESPACE -f /etc/kubernetes/addon-manifests/nfs-storage-provisioner/deployment.yaml
    kubectl create -n  $NAMESPACE -f /etc/kubernetes/addon-manifests/nfs-storage-provisioner/class.yaml
    kubectl annotate -n $NAMESPACE storageclass example-nfs storageclass.beta.kubernetes.io/is-default-class=true
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

    kubectl create -f /etc/kubernetes/addon-manifests/rook-ceph-storage-provisioner/operator.yaml
    kubectl create -f /etc/kubernetes/addon-manifests/rook-ceph-storage-provisioner/cluster.yaml
    kubectl create -f /etc/kubernetes/addon-manifests/rook-ceph-storage-provisioner/storageclass.yaml
    kubectl annotate storageclass rook-ceph-block storageclass.beta.kubernetes.io/is-default-class=true
}

function deploy_contour {
    export KUBECONFIG=/etc/kubernetes/admin.conf
    kubectl create -f /etc/kubernetes/addon-manifests/contour/common.yaml
    kubectl create -f /etc/kubernetes/addon-manifests/contour/rbac.yaml
    kubectl create -f /etc/kubernetes/addon-manifests/contour/02-contour.yaml
    kubectl create -f /etc/kubernetes/addon-manifests/contour/02-service.yaml
}

while [[ $# -gt 0 ]]
do
  key="$1"
  case $key in
    --flannel)
	deploy_flannel
	;;
    --canall)
	deploy_canal
	;;
    --calico)
	deploy_calico
	;;
    --weave)
	deploy_weave
	;;
    --nfs-provisioner)
	deploy_nfs_storage_provider
	;;
    --rook-ceph-provisioner)
	deploy_rook_ceph_storage_provider
	;;
    --dashboard)
	deploy_dashboard
	;;
    --contour)
	deploy_contour
	;;
  esac
  shift
done
