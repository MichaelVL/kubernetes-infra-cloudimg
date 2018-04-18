.PHONY: image image-w-console validate test-image test-cncf

ifndef KUBERNETES_VERSION
#KUBERNETES_VERSION=1.8.7
#KUBERNETES_VERSION=1.9.6
KUBERNETES_VERSION=1.10.1
endif

validate:
	CHECKPOINT_DISABLE=1 packer validate ubuntu1604.json

image-w-console:
	KUBERNETES_VERSION=$(KUBERNETES_VERSION) CHECKPOINT_DISABLE=1 packer build -var 'headless=false' ubuntu1604.json

image:
	KUBERNETES_VERSION=$(KUBERNETES_VERSION) CHECKPOINT_DISABLE=1 packer build ubuntu1604.json | tee build.log

# This assumes a VM running with IP address in $TESTVM_IP and injected SSH key 
test-image:
	scp -i ${SSH_KEY} test.sh ${SSH_USER}@${TESTVM_IP}:.
	ssh -i ${SSH_KEY} ${SSH_USER}@${TESTVM_IP} sudo bash ./test.sh

# This assumes a working Kubernetes cluster
# See https://github.com/cncf/k8s-conformance/blob/master/instructions.md
test-cncf:
	ssh -i ${SSH_KEY} ${SSH_USER}@${TESTVM_IP} sudo KUBECONFIG=/etc/kubernetes/admin.conf kubectl create -f /etc/kubernetes/addon-manifests/cncf-conformance-test/ && kubectl -n sonobuoy logs --follow sonobuoy
