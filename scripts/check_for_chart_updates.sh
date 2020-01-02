#!/bin/bash

# See https://github.com/helm/helm/issues/3890

HELM=helm2

$HELM repo update

UPDATE_CNT=0

DEPLOY_FILES=$(find deploy -type f -name '*.yaml')

for df in $DEPLOY_FILES; do
    #echo "File: $df"
    chart=$(cat $df | grep 'chart\:' | cut -d':' -f 2 | sed -e 's/^[[:space:]]*//')
    v=$(cat $df | grep 'version\:' | cut -d':' -f 2 | sed -e 's/^[[:space:]]*//')
    if [ ! -z $chart ] && [ ! -z $v ]; then
        s=$($HELM search -r "$chart[^-]" | tail -n +2 | cut -f 2)
        if [ $s = $v ]; then
            echo "Deploy spec: $chart, version: $v. Recent Helm repo version: $s - OK"
	else
            echo "*** Deploy spec: $chart, version: $v. Recent Helm repo version: $s - Update available!"
            let UPDATE_CNT=UPDATE_CNT+1
	fi
    fi
done

exit $UPDATE_CNT
