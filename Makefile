-include Makefile.local
-include Makefile.deploy

ifndef KUBERNETES_VERSION
KUBERNETES_VERSION=1.20.4
endif
ifndef KUBERNETES_PATCHLEVEL
KUBERNETES_PATCHLEVEL=00
endif

ifndef UBUNTU_VERSION
#UBUNTU_VERSION=1604
UBUNTU_VERSION=1804
endif

SONOBUOY_IMAGE=sonobuoy/sonobuoy:v0.16.2
KUBECFG=-v ${HOME}/.kube:${HOME}/.kube
SONOBUOY_RESULT_MOUNT=-v $(shell pwd):/results
SONOBUOY=docker run -ti --user $(shell id -u) --rm -e KUBECONFIG ${KUBECFG}:ro ${SONOBUOY_RESULT_MOUNT}:rw -w /results --entrypoint /sonobuoy ${SONOBUOY_IMAGE}

TARGET_DIR="kubeimg-${KUBERNETES_VERSION}-$(UBUNTU_VERSION)-$$(date +%Y%m%d-%H%M)"

.PHONY: validate
validate:
	CHECKPOINT_DISABLE=1 packer validate ubuntu$(UBUNTU_VERSION).json

.PHONY: image-w-console
image-w-console: build-helm-image-list
	KUBERNETES_VERSION=$(KUBERNETES_VERSION) KUBERNETES_PATCHLEVEL=$(KUBERNETES_PATCHLEVEL) CHECKPOINT_DISABLE=1 PACKER_KEY_INTERVAL=10ms packer build -color=false -var 'headless=false' ubuntu$(UBUNTU_VERSION).json
	mv output-tmp-ubuntu$(UBUNTU_VERSION) ${TARGET_DIR}

.PHONY: image
image:
	KUBERNETES_VERSION=$(KUBERNETES_VERSION) KUBERNETES_PATCHLEVEL=$(KUBERNETES_PATCHLEVEL) CHECKPOINT_DISABLE=1 PACKER_KEY_INTERVAL=10ms packer build -only=qemu -color=false ubuntu$(UBUNTU_VERSION).json | tee build.log
	mv output-tmp-ubuntu$(UBUNTU_VERSION) ${TARGET_DIR}

.PHONY: image-aws
image-aws:
	KUBERNETES_VERSION=$(KUBERNETES_VERSION) KUBERNETES_PATCHLEVEL=$(KUBERNETES_PATCHLEVEL) CHECKPOINT_DISABLE=1 PACKER_KEY_INTERVAL=10ms packer build -only=amazon-ebs -color=false ubuntu$(UBUNTU_VERSION).json | tee build.log

# This assumes a VM running with IP address in $TESTVM_IP and injected SSH key
.PHONY: test-image
test-image:
	scp -i ${SSH_KEY} test.sh ${SSH_USER}@${TESTVM_IP}:.
	ssh -i ${SSH_KEY} ${SSH_USER}@${TESTVM_IP} sudo bash ./test.sh

.PHONY: test-cncf
test-cncf:
	$(shell ${SONOBUOY} run)

.PHONY: test-cncf-status
test-cncf-status:
	$(eval SONOBUOY_STATUS =: $(shell ${SONOBUOY} status))
	@echo $(SONOBUOY_STATUS)

.PHONY: test-cncf-wait
test-cncf-wait:
	echo "Blocking on Sonobuoy"
	date
	sleep 10
	while $(shell ${SONOBUOY} status) | grep -q 'Sonobuoy is still running'; do sleep 10; done
	echo "Done!"
	date

.PHONY: test-cncf-check
test-cncf-check:
	$(eval SONOBUOY_ARCHIVE_NAME =: $(shell ${SONOBUOY} retrieve))
	$(shell ${SONOBUOY} results $(SONOBUOY_ARCHIVE_NAME))

#.PHONY: build-helm-image-list
#build-helm-image-list:
#	helm repo update
#	echo "#!/bin/bash" > scripts/helm_chart_images.sh
#	echo "set -eux" >> scripts/helm_chart_images.sh
#	echo "# This file is auto-generated - do not edit!" >> scripts/helm_chart_images.sh
#	scripts/get_helm_image_list.sh 'crictl pull' >> scripts/helm_chart_images.sh
