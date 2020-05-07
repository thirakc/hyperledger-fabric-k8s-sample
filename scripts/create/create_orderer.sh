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

echo "Creating Services for orderer"

echo "Running: kubectl create -f ${KUBECONFIG_FOLDER}/orderer/orderer-service.yaml -n ${NAMESPACE}"
kubectl create -f ${KUBECONFIG_FOLDER}/orderer/orderer-service.yaml -n ${NAMESPACE}

echo "Running: kubectl create -f ${KUBECONFIG_FOLDER}/orderer/orderer-deployment.yaml -n ${NAMESPACE}"
kubectl create -f ${KUBECONFIG_FOLDER}/orderer/orderer-deployment.yaml -n ${NAMESPACE}

ORDERER1_STATUS=$(kubectl get pods -n ${NAMESPACE} | grep orderer1-deployment | awk '{print $3}')
ORDERER2_STATUS=$(kubectl get pods -n ${NAMESPACE} | grep orderer2-deployment | awk '{print $3}')
ORDERER3_STATUS=$(kubectl get pods -n ${NAMESPACE} | grep orderer3-deployment | awk '{print $3}')
ORDERER4_STATUS=$(kubectl get pods -n ${NAMESPACE} | grep orderer4-deployment | awk '{print $3}')
ORDERER5_STATUS=$(kubectl get pods -n ${NAMESPACE} | grep orderer5-deployment | awk '{print $3}')
while [ "${ORDERER1_STATUS}" != "Running" ] && [ "${ORDERER2_STATUS}" != "Running" ] && [ "${ORDERER3_STATUS}" != "Running" ] && [ "${ORDERER4_STATUS}" != "Running" ] && [ "${ORDERER5_STATUS}" != "Running" ]; do
    if [ "${ORDERER1_STATUS}" == "Error" ] || [ "${ORDERER2_STATUS}" == "Error" ] || [ "${ORDERER3_STATUS}" == "Error" ] || [ "${ORDERER4_STATUS}" == "Error" ] || [ "${ORDERER5_STATUS}" == "Error" ]; then
        echo "There is an error in orderer pod. Please check pod logs or describe."
        exit 1
    fi
    ORDERER1_STATUS=$(kubectl get pods -n ${NAMESPACE} | grep orderer1-deployment | awk '{print $3}')
    ORDERER2_STATUS=$(kubectl get pods -n ${NAMESPACE} | grep orderer2-deployment | awk '{print $3}')
    ORDERER3_STATUS=$(kubectl get pods -n ${NAMESPACE} | grep orderer3-deployment | awk '{print $3}')
    ORDERER4_STATUS=$(kubectl get pods -n ${NAMESPACE} | grep orderer4-deployment | awk '{print $3}')
    ORDERER5_STATUS=$(kubectl get pods -n ${NAMESPACE} | grep orderer5-deployment | awk '{print $3}')
    echo "Waiting for orderer to run."
    echo "Orderer1 Status = ${ORDERER1_STATUS} | Orderer2 Status = ${ORDERER2_STATUS} | Orderer3 Status = ${ORDERER3_STATUS} | Orderer4 Status = ${ORDERER4_STATUS} | Orderer5 Status = ${ORDERER5_STATUS}"
    sleep 1
done

echo "Checking if all deployments are ready"
