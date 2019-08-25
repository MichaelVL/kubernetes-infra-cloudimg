#!/bin/bash

set -eux

apt-get install -y nfs-common

# See deployment.yaml - uses hostPath
mkdir -p /srv
