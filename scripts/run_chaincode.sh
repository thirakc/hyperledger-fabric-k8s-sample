#!/bin/bash

set -e

UPGRADE=false
export CHANNEL_NAME="test-channel"
export CHAINCODE_NAME="mycc"
export CHAINCODE_VERSION=1
#Path to the source code inside /shared folder inside chaincodeinstall pod
export CHAINCODE_PATH="chaincode/*"
#Directory within CHAINCODE_PATH that contains the chaincode code
export CHAINCODE_FOLDER="chaincode_example02"
export CHAINCODE_INIT_STRING="{\"Args\":[\"init\",\"a\",\"100\",\"b\",\"200\"]}"
export ENDOSEMENT_POLICY=""
export NAMESPACE="test-network"
export ORDERER_URL=orderer1:7050

POSITIONAL=()
while [[ $# -gt 0 ]]
do
key="$1"

case $key in
    -u|--upgrade)
		UPGRADE=true
    if [ -z "$2" ]
      then
        echo "No version specified. Specify version using --upgrade <version> e.g. --upgrade 2"
        exit 1
    fi
    CHAINCODE_VERSION="$2"
    shift # past argument
    shift # past value
    ;;
    *)    # unknown option
    POSITIONAL+=("$1") # save it in an array for later
    shift # past argument
    ;;
esac
done
set -- "${POSITIONAL[@]}" # restore positional parameters

if [ "$UPGRADE" == "true" ]
  then 
    echo "=> RUN_CHAINCODE: $CHAINCODE_NAME will be installed and UPGRADED to version $CHAINCODE_VERSION"
  else
    echo "=> RUN_CHAINCODE: $CHAINCODE_NAME will be installed and INSTANTIATED"
fi

echo ""
echo "=> RUN_CHAINCODE: Install $CHAINCODE_NAME:$CHAINCODE_VERSION on org1peer1"
kubectl exec fabric-tool -n ${NAMESPACE} \
 -- sh -c "mkdir -p /opt/gopath/src/github.com && cp -R /shared/${CHAINCODE_PATH} /opt/gopath/src/github.com/ && ls -lah /opt/gopath/src/github.com/"

kubectl exec fabric-tool -n ${NAMESPACE} \
 -- sh -c "CORE_PEER_LOCALMSPID=Org1MSP
 CORE_PEER_ADDRESS=org1peer1:7051
 CORE_PEER_TLS_ROOTCERT_FILE=/shared/crypto-config/peerOrganizations/firstorg.com/peers/org1peer1.firstorg.com/tls/ca.crt
 CORE_PEER_TLS_ENABLED=true
 peer chaincode install -n ${CHAINCODE_NAME} -v ${CHAINCODE_VERSION} -p github.com/${CHAINCODE_FOLDER}/"

echo ""
echo "=> RUN_CHAINCODE: Install $CHAINCODE_NAME:$CHAINCODE_VERSION on org2peer1"
kubectl exec fabric-tool -n ${NAMESPACE} \
 -- sh -c "CORE_PEER_LOCALMSPID=Org2MSP
  CORE_PEER_ADDRESS=org2peer1:7051
  CORE_PEER_TLS_ROOTCERT_FILE=/shared/crypto-config/peerOrganizations/secondorg.com/peers/org2peer1.secondorg.com/tls/ca.crt
  CORE_PEER_TLS_ENABLED=true
  CORE_PEER_MSPCONFIGPATH=/shared/crypto-config/peerOrganizations/secondorg.com/users/Admin@secondorg.com/msp
  peer chaincode install -n ${CHAINCODE_NAME} -v ${CHAINCODE_VERSION} -p github.com/${CHAINCODE_FOLDER}/"

# This will pull fabric-ccenv docker image prior to instantiating to make sure instantiation does not fail due to poor internet connection
echo ""
echo "=> RUN_CHAINCODE: Pulling fabric-ccenv image for org1peer1"
kubectl exec $(kubectl get pod -n ${NAMESPACE} | grep org1peer1-deployment | awk '{print $1}') -c dind -n ${NAMESPACE} docker pull hyperledger/fabric-ccenv:1.4.4
kubectl exec $(kubectl get pod -n ${NAMESPACE} | grep org1peer1-deployment | awk '{print $1}') -c dind -n ${NAMESPACE} docker tag hyperledger/fabric-ccenv:1.4.4 hyperledger/fabric-ccenv:latest

kubectl exec $(kubectl get pod -n ${NAMESPACE} | grep org2peer1-deployment | awk '{print $1}') -c dind -n ${NAMESPACE} docker pull hyperledger/fabric-ccenv:1.4.4
kubectl exec $(kubectl get pod -n ${NAMESPACE} | grep org2peer1-deployment | awk '{print $1}') -c dind -n ${NAMESPACE} docker tag hyperledger/fabric-ccenv:1.4.4 hyperledger/fabric-ccenv:latest

if [ "$UPGRADE" == "true" ]; then
  echo ""
  echo "=> RUN_CHAINCODE: Upgrade $CHAINCODE_NAME to version ${CHAINCODE_VERSION} on channel \"${CHANNEL_NAME}\" using \"Org1MSP\""
  kubectl exec fabric-tool -n ${NAMESPACE} \
    -- sh -c "CORE_PEER_LOCALMSPID=Org1MSP
    CORE_PEER_ADDRESS=org1peer1:7051
    CORE_PEER_TLS_ROOTCERT_FILE=/shared/crypto-config/peerOrganizations/firstorg.com/peers/org1peer1.firstorg.com/tls/ca.crt
    CORE_PEER_TLS_ENABLED=true
    peer chaincode upgrade -o ${ORDERER_URL} --tls --cafile /shared/crypto-config/ordererOrganizations/ordererorg/orderers/blockchain-orderer/tls/ca.crt -C ${CHANNEL_NAME} -n ${CHAINCODE_NAME} -v ${CHAINCODE_VERSION} -c '${CHAINCODE_INIT_STRING}' -P 'OR(\"Org1MSP.peer\",\"Org2MSP.peer\")'"
else
  echo ""
  echo "=> RUN_CHAINCODE: Instantiate $CHAINCODE_NAME:$CHAINCODE_VERSION on channel \"${CHANNEL_NAME}\" using \"Org1MSP\""
  kubectl exec fabric-tool -n ${NAMESPACE} \
    -- sh -c "CORE_PEER_LOCALMSPID=Org1MSP
    CORE_PEER_ADDRESS=org1peer1:7051
    CORE_PEER_TLS_ROOTCERT_FILE=/shared/crypto-config/peerOrganizations/firstorg.com/peers/org1peer1.firstorg.com/tls/ca.crt
    CORE_PEER_TLS_ENABLED=true
    peer chaincode instantiate -o ${ORDERER_URL} --tls --cafile /shared/crypto-config/ordererOrganizations/blockchain.com/orderers/orderer1.blockchain.com/msp/tlscacerts/tlsordererca-cert.pem -C ${CHANNEL_NAME} -n ${CHAINCODE_NAME} -v ${CHAINCODE_VERSION} -c '${CHAINCODE_INIT_STRING}' -P 'OR(\"Org1MSP.peer\",\"Org2MSP.peer\")'"
fi

echo ""
echo "=> RUN_CHAINCODE: Querying to ensure instantiation/upgrade is successful.."
sleep 3
kubectl exec fabric-tool -n ${NAMESPACE} -- peer chaincode query -C ${CHANNEL_NAME} -n ${CHAINCODE_NAME} -c '{"Args":["query", "a"]}'
echo "Done!!"
