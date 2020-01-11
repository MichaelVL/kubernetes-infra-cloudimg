#!/bin/bash

set -eux

echo "--> Pulling K-Rail image"

crictl pull cruise/k-rail:release-v1.1.1
