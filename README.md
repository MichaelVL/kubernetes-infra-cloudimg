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
 - Ingress controllers
   * [Contour](https://github.com/heptio/contour)
   * [Traefik](https://traefik.io/) 
 - Storage Providers
   * [NFS storage provider](https://github.com/kubernetes-incubator/external-storage/tree/master/nfs)
   * [ROOK+CEPH storage provider](https://github.com/rook/rook)
 - [MetalLB load balancer](https://metallb.universe.tf)

The manifests for deploying these add-ons are either from the stable helm charts
(see [helmfile.yaml](deply/helmfile.yaml)) or stored in /etc/kubernetes/addon-manifests/

A build-test are available that can be executed against a running VM - see Makefile for details