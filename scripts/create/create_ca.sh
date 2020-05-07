#!/bin/bash

if [ "${PWD##*/}" == "create" ]; then
    KUBECONFIG_FOLDER=${PWD}/../../kube-configs
elif [ "${PWD##*/}" == "scripts" ]; then
    KUBECONFIG_FOLDER=${PWD}/../kube-configs
else
    echo "Please run the script from 'scripts' or 'scripts/create' folder"
fi

NAMESPACE=default

Parse_Arguments() {
	while [ $# -gt 0 ]; do
		case $1 in
			-n | --namespace)
				echo "Configured to setup a namespace"
				NAMESPACE=$2
				;;
			--include-volumes | -i)
				DELETE_VOLUMES=true
				;;
		esac
		shift
	done
}

Parse_Arguments $@

echo "Creating Services for certificate authority"

echo "Running: kubectl create -f ${KUBECONFIG_FOLDER}/fabric-ca.yaml -n ${NAMESPACE}"
kubectl create -f ${KUBECONFIG_FOLDER}/fabric-ca.yaml -n ${NAMESPACE}

STATUS=$(kubectl get pods -n ${NAMESPACE} | grep ca-deployment | awk '{print $3}')
while [ "${STATUS}" != "Running" ]; do
    if [ "${STATUS}" == "Error" ]; then
        echo "There is an error in CA pod. Please check pod logs or describe."
        exit 1
    fi
    STATUS=$(kubectl get pods -n ${NAMESPACE} | grep ca-deployment | awk '{print $3}')
    echo "Waiting for CA to run. Status = ${STATUS}"
    sleep 1
done

echo "Checking if all deployments are ready"