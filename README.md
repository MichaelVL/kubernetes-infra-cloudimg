## Kubernetes Infrastructure Cloud-image

This repo contains a Kubernetes infrastructure cloud-image with pre-pulled
images for the main Kubernetes infrastructure.  The Kubernetes version can be
configured through the variable KUBERNETES_VERSION.

The image is configured with cloud-init, no swap and based on Ubuntu and build
with Packer.
