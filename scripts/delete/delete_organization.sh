#!/bin/bash

if [ "${PWD##*/}" == "create" ]; then
    KUBECONFIG_FOLDER=${PWD}/../../kube-configs
elif [ "${PWD##*/}" == "scripts" ]; then
    KUBECONFIG_FOLDER=${PWD}/../kube-configs
else
    echo "Please run the script from 'scripts' or 'scripts/create' folder"
fi

NAMESPACE=default
ORGANIZATION="org1 org2"

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

echo "Deleting Services for organization"

for orgName in ${ORGANIZATION}; do
  echo "Running: kubectl delete -f ${KUBECONFIG_FOLDER}/${orgName}/${orgName}-service.yaml -n ${NAMESPACE}"
  kubectl delete -f ${KUBECONFIG_FOLDER}/${orgName}/${orgName}-service.yaml -n ${NAMESPACE}

  echo "Running: kubectl delete -f ${KUBECONFIG_FOLDER}/${orgName}/${orgName}-deployment.yaml -n ${NAMESPACE}"
  kubectl delete -f ${KUBECONFIG_FOLDER}/${orgName}/${orgName}-deployment.yaml -n ${NAMESPACE}

  sleep 1
done