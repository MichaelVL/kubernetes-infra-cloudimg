.PHONY: validate image image-w-console test-image test-cncf build-helm-image-list

ifndef KUBERNETES_VERSION
KUBERNETES_VERSION=1.11.3
endif

TARGET_DIR="kubeimg-${KUBERNETES_VERSION}-$$(date +%Y%m%d-%H%M)"

validate:
	CHECKPOINT_DISABLE=1 packer validate ubuntu1604.json

image-w-console: build-helm-image-list
	KUBERNETES_VERSION=$(KUBERNETES_VERSION) CHECKPOINT_DISABLE=1 PACKER_KEY_INTERVAL=10ms packer build -color=false -var 'headless=false' ubuntu1604.json
	mv output-tmp-ubuntu1604 ${TARGET_DIR}

image: build-helm-image-list
	KUBERNETES_VERSION=$(KUBERNETES_VERSION) CHECKPOINT_DISABLE=1 PACKER_KEY_INTERVAL=10ms packer build -color=false ubuntu1604.json | tee build.log
	mv output-tmp-ubuntu1604 ${TARGET_DIR}

# This assumes a VM running with IP address in $TESTVM_IP and injected SSH key 
test-image:
	scp -i ${SSH_KEY} test.sh ${SSH_USER}@${TESTVM_IP}:.
	ssh -i ${SSH_KEY} ${SSH_USER}@${TESTVM_IP} sudo bash ./test.sh

test-cncf:
	sonobuoy run

build-helm-image-list:
	echo "#!/bin/bash" > scripts/helm_chart_images.sh
	echo "set -eux" >> scripts/helm_chart_images.sh
	echo "# This file is auto-generated - do not edit!" >> scripts/helm_chart_images.sh
	scripts/get_helm_image_list.sh 'docker pull' >> scripts/helm_chart_images.sh
