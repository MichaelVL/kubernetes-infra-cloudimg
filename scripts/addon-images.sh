#!/bin/bash -eux

echo "--> Installing Docker base images"
docker pull python:2-slim
docker pull nginx
docker pull busybox

echo "--> Images available after installing additional images"
docker images
