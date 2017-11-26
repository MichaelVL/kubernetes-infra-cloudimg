## Kubernetes Infrastructure Cloud-image

This repo contains a Kubernetes infrastructure cloud-image with pre-pulled
images for the main Kubernetes infrastructure.  The Kubernetes version can be
configured through the variable KUBERNETES_VERSION.

The image is configured with cloud-init, no swap and based on Ubuntu and build
with Packer.

The following add-ons are also included (images and manifests):

 - Network plugin Canal (Flannel+Calico)
 - Kubernetes dashboard
 - Helm (tiller, image only)
 - [Elasticsearch, Fluentd, Kibana](https://github.com/kubernetes/kubernetes/tree/master/cluster/addons/fluentd-elasticsearch)
 - [Nginx ingress controller](https://github.com/kubernetes/ingress-nginx)
 - [NFS storage provider](https://github.com/kubernetes-incubator/external-storage/tree/master/nfs)
 - [CNCF conformance test](https://github.com/cncf/k8s-conformance) (manifest only)

The manifests for deploying these add-ons are stored in /etc/kubernetes/addon-manifests/

Two build-test are available that can be executed against a running VM or
a running Kubernetes cluster - see Makefile for details:

 - A shell script that verifies basic Linux configuration
 - [CNCF conformance tests](https://github.com/cncf/k8s-conformance/blob/master/instructions.md)