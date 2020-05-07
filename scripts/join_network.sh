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

echo ""
echo "Running create channel"
kubectl exec fabric-tool -n ${NAMESPACE} \
 -- sh -c 'CORE_PEER_MSPCONFIGPATH=/shared/crypto-config/peerOrganizations/firstorg.com/users/Admin@firstorg.com/msp
  CORE_PEER_ADDRESS=org1peer1:7051
  CORE_PEER_LOCALMSPID="Org1MSP"
  CORE_PEER_TLS_ROOTCERT_FILE=/shared/crypto-config/peerOrganizations/firstorg.com/peers/org1peer1.firstorg.com/tls/ca.crt
  CHANNEL_NAME=test-channel
  ORDERER_CA_TLS=/shared/crypto-config/ordererOrganizations/blockchain.com/orderers/orderer1.blockchain.com/msp/tlscacerts/tlsordererca-cert.pem
  peer channel create -o ${ORDERER_URL} -c ${CHANNEL_NAME} -f ./shared/channel-artifacts/test-channel.tx --tls --cafile ${ORDERER_CA_TLS}'
sleep 2

echo ""
echo "Join channel on org1 peer1"
kubectl exec fabric-tool -n ${NAMESPACE} \
 -- sh -c 'peer channel join -b ${CHANNEL_NAME}.block'
sleep 1

echo ""
echo "Update anchor on org1 peer1"
kubectl exec fabric-tool -n ${NAMESPACE} \
 -- sh -c 'peer channel update -o ${ORDERER_URL} -c ${CHANNEL_NAME} -f ./shared/channel-artifacts/test-channelOrg1MSPanchors.tx --tls --cafile ${ORDERER_CA_TLS}'
sleep 1

echo ""
echo "Join channel on org1 peer2"
kubectl exec fabric-tool -n ${NAMESPACE} \
 -- sh -c 'CORE_PEER_ADDRESS=org1peer2:7051
 CORE_PEER_TLS_ROOTCERT_FILE=/shared/crypto-config/peerOrganizations/firstorg.com/peers/org1peer2.firstorg.com/tls/ca.crt
 peer channel join -b ${CHANNEL_NAME}.block'
sleep 1

echo ""
echo "Join channel on org2 peer1"
kubectl exec fabric-tool -n ${NAMESPACE} \
 -- sh -c 'CORE_PEER_MSPCONFIGPATH=/shared/crypto-config/peerOrganizations/secondorg.com/users/Admin@secondorg.com/msp
  CORE_PEER_ADDRESS=org2peer1:7051
  CORE_PEER_LOCALMSPID="Org2MSP"
  CORE_PEER_TLS_ROOTCERT_FILE=/shared/crypto-config/peerOrganizations/secondorg.com/peers/org2peer1.secondorg.com/tls/ca.crt
  peer channel join -b ${CHANNEL_NAME}.block'
sleep 1

echo ""
echo "Update anchor on org2 peer1"
kubectl exec fabric-tool -n ${NAMESPACE} \
 -- sh -c 'CORE_PEER_MSPCONFIGPATH=/shared/crypto-config/peerOrganizations/secondorg.com/users/Admin@secondorg.com/msp
 CORE_PEER_ADDRESS=org2peer1:7051
 CORE_PEER_LOCALMSPID="Org2MSP"
 ORDERER_CA_TLS=/shared/crypto-config/ordererOrganizations/blockchain.com/orderers/orderer1.blockchain.com/msp/tlscacerts/tlsordererca-cert.pem
 peer channel update -o ${ORDERER_URL} -c ${CHANNEL_NAME} -f ./shared/channel-artifacts/test-channelOrg2MSPanchors.tx --tls --cafile ${ORDERER_CA_TLS}'
sleep 1

echo ""
echo "Join channel on org2 peer2"
kubectl exec fabric-tool -n ${NAMESPACE} \
 -- sh -c 'CORE_PEER_MSPCONFIGPATH=/shared/crypto-config/peerOrganizations/secondorg.com/users/Admin@secondorg.com/msp
 CORE_PEER_ADDRESS=org2peer2:7051
 CORE_PEER_LOCALMSPID="Org2MSP"
 CORE_PEER_TLS_ROOTCERT_FILE=/shared/crypto-config/peerOrganizations/secondorg.com/peers/org2peer2.secondorg.com/tls/ca.crt
 peer channel join -b ${CHANNEL_NAME}.block'
sleep 1