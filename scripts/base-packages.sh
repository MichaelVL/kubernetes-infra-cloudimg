#!/bin/bash

set -eux

apt-get update
apt-get install -y ntp git ubuntu-keyring debian-archive-keyring debian-keyring
