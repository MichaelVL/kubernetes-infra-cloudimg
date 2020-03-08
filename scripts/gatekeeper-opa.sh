#!/bin/bash

set -eux

echo "--> Pulling Gatekeeper image"

crictl pull quay.io/open-policy-agent/gatekeeper:v3.1.0-beta.7
