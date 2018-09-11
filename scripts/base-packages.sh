#!/bin/bash

set -eux

apt-get update
apt-get install -y ntp unattended-upgrades ubuntu-keyring debian-archive-keyring debian-keyring
