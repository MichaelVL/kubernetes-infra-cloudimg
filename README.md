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

 - Network plugins Flannel, Weave-net, Calico, Canal (Flannel+Calico)
 - Kubernetes dashboard
 - Helm (tiller, image only)
 - Prometheus and Grafana (images only - as used by stable Helm charts)
 - [Contour](https://github.com/heptio/contour) ingress controller (in a variant that supports internal and external services)
 - Storage Providers
   * [NFS storage provider](https://github.com/kubernetes-incubator/external-storage/tree/master/nfs)
   * [ROOK+CEPH storage provider](https://github.com/rook/rook)
 - [MetalLB load balancer](https://metallb.universe.tf)
 - Metrics server (note [issue 146](https://github.com/kubernetes-incubator/metrics-server/issues/146))
 - Cert-manager

The manifests for deploying these add-ons are either from the stable helm charts
(see [helmsman.yaml](deply/helmsman.yaml)) or stored in /etc/kubernetes/addon-manifests/

A build-test are available that can be executed against a running VM - see Makefile for details.
