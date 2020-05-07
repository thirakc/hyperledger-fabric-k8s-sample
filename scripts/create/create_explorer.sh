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

echo "Creating Explorer DB.."

echo "Running: kubectl create -f ${KUBECONFIG_FOLDER}/explorerdb.yaml"
kubectl create -f ${KUBECONFIG_FOLDER}/explorerdb.yaml -n ${NAMESPACE}

echo "Checking if Explorer DB is ready"

NUMPENDING=$(kubectl get deployments -n ${NAMESPACE} | grep explorerdb | awk '{print $2}' | grep 0/1 | wc -l | awk '{print $1}')
while [ "${NUMPENDING}" != "0" ]; do
    echo "Waiting on pending deployments. Deployments pending = ${NUMPENDING}"
    NUMPENDING=$(kubectl get deployments -n ${NAMESPACE} | grep explorerdb | awk '{print $2}' | grep 0/1 | wc -l | awk '{print $1}')
    sleep 5
done

echo "Creating Hyperledger Explorer.."

echo "Running: kubectl create -f ${KUBECONFIG_FOLDER}/explorer.yaml"
kubectl create -f ${KUBECONFIG_FOLDER}/explorer.yaml -n ${NAMESPACE}

echo "Checking if Hyperledger Explorer is ready"

NUMPENDING=$(kubectl get deployments -n ${NAMESPACE} | grep explorer | awk '{print $2}' | grep 0/1 | wc -l | awk '{print $1}')
while [ "${NUMPENDING}" != "0" ]; do
    echo "Waiting on pending deployments. Deployments pending = ${NUMPENDING}"
    NUMPENDING=$(kubectl get deployments -n ${NAMESPACE} | grep explorer | awk '{print $2}' | grep 0/1 | wc -l | awk '{print $1}')
    sleep 5
done
