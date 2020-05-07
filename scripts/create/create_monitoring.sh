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

echo "Creating Monitoring server.."

echo "Running: kubectl create -f ${KUBECONFIG_FOLDER}/monitoring.yaml -n ${NAMESPACE}"
kubectl create -f ${KUBECONFIG_FOLDER}/monitoring.yaml -n ${NAMESPACE}

echo "Checking if Monitoring is ready"

NUMPENDING=$(kubectl get deployments -n ${NAMESPACE} | grep monitoring | awk '{print $2}' | grep 0/1 | wc -l | awk '{print $1}')
while [ "${NUMPENDING}" != "0" ]; do
    echo "Waiting on pending deployments. Deployments pending = ${NUMPENDING}"
    NUMPENDING=$(kubectl get deployments -n ${NAMESPACE} | grep monitoring | awk '{print $2}' | grep 0/1 | wc -l | awk '{print $1}')
    sleep 5
done

echo "Creating Grafana server.."

echo "Running: kubectl create -f ${KUBECONFIG_FOLDER}/grafana.yaml -n ${NAMESPACE}"
kubectl create -f ${KUBECONFIG_FOLDER}/grafana.yaml -n ${NAMESPACE}

echo "Checking if Grafana is ready"

NUMPENDING=$(kubectl get deployments -n ${NAMESPACE} | grep grafana | awk '{print $2}' | grep 0/1 | wc -l | awk '{print $1}')
while [ "${NUMPENDING}" != "0" ]; do
    echo "Waiting on pending deployments. Deployments pending = ${NUMPENDING}"
    NUMPENDING=$(kubectl get deployments -n ${NAMESPACE} | grep grafana | awk '{print $2}' | grep 0/1 | wc -l | awk '{print $1}')
    sleep 5
done
