## Kubernetes Infrastructure Cloud-image

This repo contains a Kubernetes infrastructure cloud-image with pre-pulled
images for the main Kubernetes infrastructure.  The Kubernetes version can be
configured through the variable KUBERNETES_VERSION.

The image is based on Ubuntu, configured with cloud-init, no swap and build with
Packer.

The image contain the installed Kubernetes version in the file
/etc/kubernetes_version, e.g. building a cluster could be achieved with (on a VM
created from the build image):

```
kubeadm init --kubernetes-version "$(cat /etc/kubernetes_version)"
```


The following add-ons are also included (images and manifests):

 - Network plugin Canal (Flannel+Calico)
 - Kubernetes dashboard
 - Helm (tiller, image only)
 - Prometheus and Grafana (images only - as used by stable Helm charts)
 - [Elasticsearch, Fluentd, Kibana](https://github.com/kubernetes/kubernetes/tree/master/cluster/addons/fluentd-elasticsearch)
 - [Nginx ingress controller](https://github.com/kubernetes/ingress-nginx)
 - [NFS storage provider](https://github.com/kubernetes-incubator/external-storage/tree/master/nfs)
 - [CNCF conformance test](https://github.com/cncf/k8s-conformance) (manifest only)

The manifests for deploying these add-ons are stored in /etc/kubernetes/addon-manifests/

Two build-test are available that can be executed against a running VM or
a running Kubernetes cluster - see Makefile for details:

 - A shell script that verifies basic Linux configuration
 - [CNCF conformance tests](https://github.com/cncf/k8s-conformance/blob/master/instructions.md)