-include Makefile.local
-include Makefile.deploy

.PHONY: validate image image-w-console test-image build-helm-image-list
.PHONY: test-cncf test-cncf-wait test-cncf-retrieve test-cncf-check

ifndef KUBERNETES_VERSION
KUBERNETES_VERSION=1.15.0
endif
ifndef KUBERNETES_PATCHLEVEL
KUBERNETES_PATCHLEVEL=00
endif

ifndef UBUNTU_VERSION
UBUNTU_VERSION=1604
endif


TARGET_DIR="kubeimg-${KUBERNETES_VERSION}-$(UBUNTU_VERSION)-$$(date +%Y%m%d-%H%M)"

validate:
	CHECKPOINT_DISABLE=1 packer validate ubuntu$(UBUNTU_VERSION).json

image-w-console: build-helm-image-list
	KUBERNETES_VERSION=$(KUBERNETES_VERSION) KUBERNETES_PATCHLEVEL=$(KUBERNETES_PATCHLEVEL) CHECKPOINT_DISABLE=1 PACKER_KEY_INTERVAL=10ms packer build -color=false -var 'headless=false' ubuntu$(UBUNTU_VERSION).json
	mv output-tmp-ubuntu$(UBUNTU_VERSION) ${TARGET_DIR}

image: build-helm-image-list
	KUBERNETES_VERSION=$(KUBERNETES_VERSION) KUBERNETES_PATCHLEVEL=$(KUBERNETES_PATCHLEVEL) CHECKPOINT_DISABLE=1 PACKER_KEY_INTERVAL=10ms packer build -color=false ubuntu$(UBUNTU_VERSION).json | tee build.log
	mv output-tmp-ubuntu$(UBUNTU_VERSION) ${TARGET_DIR}

# This assumes a VM running with IP address in $TESTVM_IP and injected SSH key 
test-image:
	scp -i ${SSH_KEY} test.sh ${SSH_USER}@${TESTVM_IP}:.
	ssh -i ${SSH_KEY} ${SSH_USER}@${TESTVM_IP} sudo bash ./test.sh

test-cncf:
	sonobuoy run

test-cncf-wait:
	echo "Blocking on Sonobuoy"
	date
	sleep 10
	while sonobuoy status | grep -q 'Sonobuoy is still running'; do sleep 10; done
	echo "Done!"
	date

test-cncf-retrieve:
	sonobuoy retrieve

test-cncf-check:
	$(eval SONOBUOY_UUID := $(shell kubectl -n heptio-sonobuoy get configmap sonobuoy-config-cm -o "jsonpath={.data['config\.json']}" | jq '.UUID' | sed -e 's/^"//' -e 's/"$$//'))
	$(eval SONOBUOY_TS := $(shell kubectl -n heptio-sonobuoy get configmap sonobuoy-config-cm -o jsonpath='{.metadata.creationTimestamp}' | awk '{print substr($$0,1,4) substr($$0,6,2) substr($$0,9,2) substr($$0,12,2) substr($$0,15,2)}'))
	$(eval SONOBUOY_ARCHIVE_NAME := $(SONOBUOY_TS)_sonobuoy_$(SONOBUOY_UUID).tar.gz)
	sonobuoy e2e $(SONOBUOY_ARCHIVE_NAME) --show passed
	sonobuoy e2e $(SONOBUOY_ARCHIVE_NAME) --show failed

build-helm-image-list:
	helm repo update
	echo "#!/bin/bash" > scripts/helm_chart_images.sh
	echo "set -eux" >> scripts/helm_chart_images.sh
	echo "# This file is auto-generated - do not edit!" >> scripts/helm_chart_images.sh
	scripts/get_helm_image_list.sh 'crictl pull' >> scripts/helm_chart_images.sh
