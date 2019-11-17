#!/bin/bash

#set -xe

KUBEAUDIT_IMAGE=michaelvl/kubeaudit:0.7.0
MANIFESTS="-v $(pwd):/work"
KUBEAUDIT_CMD="docker run --user $(id -u):$(id -g) --rm $MANIFESTS:ro ${KUBEAUDIT_IMAGE}"
${KUBEAUDIT_CMD} "$@"
