#!/bin/bash -eux

echo "--> Installing Docker base images"
docker pull busybox
docker pull python:2-slim
docker pull nginx:1.11-alpine
docker pull bitnami/rabbitmq:3.7.2-r1
docker pull bitnami/mongodb:3.7.1-r0

echo "--> Images available after installing additional images"
docker images
