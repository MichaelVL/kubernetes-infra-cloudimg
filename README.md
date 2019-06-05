## Kubernetes Infrastructure Base

This repo contains a Kubernetes infrastructure VM base-image with pre-pulled
images for the main Kubernetes infrastructure. Included is also a number of
curated infrastructure applications necessary to build a useful Kubernetes
infrastructure.

The following applications are included (images and/or manifests):

 - Network plugins Flannel, Weave-net, Calico, Canal (Flannel+Calico)
 - Kubernetes dashboard
 - Helm (tiller, image only)
 - Prometheus and Grafana
   * Kubernetes Health Dashboard from this [dashboards as code project](https://github.com/MichaelVL/kubernetes-grafana-dashboard)
 - [Loki log management](https://grafana.com/loki)
 - Ingress controllers in variants that supports internal and external services (See [here for a description of Contour in this dual-ingress controller setup](https://github.com/MichaelVL/contour-envoy-helm-chart)):
   * [Contour ingress controllers](https://github.com/heptio/contour)
   * [Istio ingress gateways](https://istio.io/)
 - Storage Providers
   * [NFS storage provider](https://github.com/kubernetes-incubator/external-storage/tree/master/nfs)
   * [ROOK+CEPH storage provider](https://github.com/rook/rook)
 - [MetalLB load balancer/virtual IP solution](https://metallb.universe.tf)
 - Metrics server (note [issue 146](https://github.com/kubernetes-incubator/metrics-server/issues/146))
 - Cert-manager

The manifests for deploying these add-ons are either from the stable helm charts
(see [helmsman.yaml](deply/helmsman.yaml) and other files in the deploy folder)
or stored in /etc/kubernetes/addon-manifests/

The VM base image is based on Ubuntu, configured with cloud-init, no swap and
build with Packer.  The Kubernetes version can be configured through the
variable KUBERNETES_VERSION.

The image contain the installed Kubernetes version in the file
/etc/kubernetes_version, e.g. building a cluster could be achieved with
[kubeadm](https://kubernetes.io/docs/setup/independent/create-cluster-kubeadm/)
(on a VM created from the build image):

```
kubeadm init --kubernetes-version "$(cat /etc/kubernetes_version)"
```

## Testing

A build-test are available that can be executed against a running VM - see Makefile for details.

The [CNCF conformmance
test](https://github.com/cncf/k8s-conformance/blob/master/instructions.md) can
be executed using the make target `test-cncf`


