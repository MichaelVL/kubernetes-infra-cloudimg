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
 - Elasticsearch, Fluentd, Kibana
 - Nginx ingress controller
 - CNCF conformance test (manifest only)

The manifests for deploying these add-ons are stored in /etc/kubernetes/addon-manifests/

Two build-test types are available that can be executed against a running VM or
a running Kubernetes cluster - see Makefile for details:

 - A simple shell script that verifies basic Linux configuration
 - [CNCF conformance tests](https://github.com/cncf/k8s-conformance/blob/master/instructions.md)