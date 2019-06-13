#!/bin/bash

set -eux

echo "--> Pulling a selection of Docker base images"
crictl pull busybox
crictl pull python:2-slim
crictl pull nginx:1.11-alpine
crictl pull bitnami/rabbitmq:3.7.2-r1
crictl pull bitnami/mongodb:3.7.1-r0

echo "--> Images available after installing additional images"
crictl images
