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

echo "Creating Persistent Volumes"
if [ "$(kubectl get pvc -n ${NAMESPACE} | grep shared-pvc | awk '{print $2}')" != "Bound" ]; then
	echo "The Persistent Volume does not seem to exist or is not bound"
	echo "Creating Persistent Volume"

	# making a pv on kubernetes
	echo "Running: kubectl create -f ${KUBECONFIG_FOLDER}/shared-storage.yaml -n ${NAMESPACE}"
	kubectl create -f ${KUBECONFIG_FOLDER}/shared-storage.yaml -n ${NAMESPACE}
	sleep 5
	if [ "kubectl get pvc -n ${NAMESPACE} | grep shared-pvc | awk '{print $3}'" != "shared-pv" ]; then
		echo "Success creating PV"
	else
		echo "Failed to create PV"
	fi
else
	echo "The Persistent Volume exists, not creating again"
fi