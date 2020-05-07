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

echo "Creating fabric tool"
kubectl apply -f ../kube-configs/fabric-tool.yaml -n ${NAMESPACE}

STATUS=$(kubectl get pods fabric-tool -n ${NAMESPACE} | grep fabric-tool | awk '{print $3}')
while [ "${STATUS}" != "Running" ]; do
    if [ "${STATUS}" == "Error" ]; then
        echo "There is an error in fabric-tool pod. Please run 'kubectl logs fabric-tool' or 'kubectl describe pod fabric-tool'."
        exit 1
    fi
    STATUS=$(kubectl get pods fabric-tool -n ${NAMESPACE} | grep fabric-tool | awk '{print $3}')
    echo "Waiting for fabric-tool to run. Status = ${STATUS}"
    sleep 1
done