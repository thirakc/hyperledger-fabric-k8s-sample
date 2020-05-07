#!/bin/bash
if [ "${PWD##*/}" == "delete" ]; then
    KUBECONFIG_FOLDER=${PWD}/../../kube-configs
elif [ "${PWD##*/}" == "scripts" ]; then
    KUBECONFIG_FOLDER=${PWD}/../kube-configs
else
    echo "Please run the script from 'scripts' or 'scripts/delete' folder"
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

echo "Deleting Hyperledger Explorer Pod and Service"
echo "Running: kubectl delete -f ${KUBECONFIG_FOLDER}/explorer.yaml -n ${NAMESPACE}"
kubectl delete -f ${KUBECONFIG_FOLDER}/explorer.yaml -n ${NAMESPACE}

echo "Deleting DB Pod and Service"
echo "Running: kubectl delete -f ${KUBECONFIG_FOLDER}/explorerdb.yaml -n ${NAMESPACE}"
kubectl delete -f ${KUBECONFIG_FOLDER}/explorerdb.yaml -n ${NAMESPACE}
