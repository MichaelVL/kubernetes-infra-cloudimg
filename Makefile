.PHONY: image image-w-console validate test-image

validate:
	CHECKPOINT_DISABLE=1 packer validate ubuntu1604.json

image-w-console:
	CHECKPOINT_DISABLE=1 packer build -var 'headless=false' ubuntu1604.json

image:
	CHECKPOINT_DISABLE=1 packer build ubuntu1604.json

# This assumes a VM running with IP address in $TESTVM_IP and injected SSH key 
test-image:
	scp -i ${SSH_KEY} test.sh ${SSH_USER}@${TESTVM_IP}:.
	ssh -i ${SSH_KEY} ${SSH_USER}@${TESTVM_IP} sudo bash ./test.sh
