.PHONY: image image-w-console validate test-image test-cncf

validate:
	CHECKPOINT_DISABLE=1 packer validate ubuntu1604.json

image-w-console:
	CHECKPOINT_DISABLE=1 packer build -var 'headless=false' ubuntu1604.json

image:
	CHECKPOINT_DISABLE=1 packer build ubuntu1604.json | tee build.log

# This assumes a VM running with IP address in $TESTVM_IP and injected SSH key 
test-image:
	scp -i ${SSH_KEY} test.sh ${SSH_USER}@${TESTVM_IP}:.
	ssh -i ${SSH_KEY} ${SSH_USER}@${TESTVM_IP} sudo bash ./test.sh

# This assumes a working Kubernetes cluster
# See https://github.com/cncf/k8s-conformance/blob/master/instructions.md
test-cncf:
	ssh -i ${SSH_KEY} ${SSH_USER}@${TESTVM_IP} sudo kubectl create -f /etc/kubernetes/addon-manifests/cncf-conformance-test/ && watch kubectl -n sonobuoy logs sonobuoy
