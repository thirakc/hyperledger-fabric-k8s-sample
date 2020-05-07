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

echo "Creating Services for organization"

for orgName in ${ORGANIZATION}; do
  echo "Running: kubectl create -f ${KUBECONFIG_FOLDER}/${orgName}/${orgName}-service.yaml -n ${NAMESPACE}"
  kubectl create -f ${KUBECONFIG_FOLDER}/${orgName}/${orgName}-service.yaml -n ${NAMESPACE}

  echo "Running: kubectl create -f ${KUBECONFIG_FOLDER}/${orgName}/${orgName}-deployment.yaml -n ${NAMESPACE}"
  kubectl create -f ${KUBECONFIG_FOLDER}/${orgName}/${orgName}-deployment.yaml -n ${NAMESPACE}

  sleep 1
done

#for orgName in ${ORGANIZATION}; do
#  PEER1_STATUS=$(kubectl get pods -n ${NAMESPACE} | grep ${orgName}peer1-deployment | awk '{print $3}')
#  PEER2_STATUS=$(kubectl get pods -n ${NAMESPACE} | grep ${orgName}peer2-deployment | awk '{print $3}')
#  while [ "${PEER1_STATUS}" != "Running" ] && [ "${PEER2_STATUS}" != "Running" ]; do
#      if [ "${STATUS}" == "Error" ]; then
#          echo "There is an error in ${orgName} pod. Please check pod logs or describe."
#          exit 1
#      fi
#      PEER1_STATUS=$(kubectl get pods -n ${NAMESPACE} | grep ${orgName}peer1-deployment | awk '{print $3}')
#      PEER2_STATUS=$(kubectl get pods -n ${NAMESPACE} | grep ${orgName}peer2-deployment | awk '{print $3}')
#      echo "Waiting for ${orgName} to run. Peer1 Status = ${PEER1_STATUS}, Peer2 Status = ${PEER2_STATUS}"
#      sleep 1
#  done
#done

for orgName in ${ORGANIZATION}; do
  PEER1_NUMPENDING=$(kubectl get deployments -n ${NAMESPACE} | grep ${orgName}peer1-deployment | awk '{print $2}' | grep 0/1 | wc -l | awk '{print $1}')
  PEER2_NUMPENDING=$(kubectl get deployments -n ${NAMESPACE} | grep ${orgName}peer2-deployment | awk '{print $2}' | grep 0/1 | wc -l | awk '{print $1}')
  while [ "${PEER1_NUMPENDING}" != "0" ] && [ "${PEER2_NUMPENDING}" != "0" ]; do
    echo "Waiting on pending ${orgName} deployments. Peer1 Deployments pending = ${PEER1_NUMPENDING}, Peer2 Deployments pending = ${PEER2_NUMPENDING}"
    PEER1_NUMPENDING=$(kubectl get deployments -n ${NAMESPACE} | grep ${orgName}peer1-deployment | awk '{print $2}' | grep 0/1 | wc -l | awk '{print $1}')
    PEER2_NUMPENDING=$(kubectl get deployments -n ${NAMESPACE} | grep ${orgName}peer2-deployment | awk '{print $2}' | grep 0/1 | wc -l | awk '{print $1}')
    sleep 2
  done
done

echo "Checking if all deployments are ready"