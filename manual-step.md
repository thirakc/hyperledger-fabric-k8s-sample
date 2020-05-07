# Start & Demonstrate chaincode
## Execute into fabric tool (CLI)
``` bash
kubec exec -it fabric-tools -n test-network bash
```

## Export org1peer1 profile
``` bash
CORE_PEER_MSPCONFIGPATH=/shared/crypto-config/peerOrganizations/firstorg.com/users/Admin@firstorg.com/msp
CORE_PEER_ADDRESS=org1peer1:7051
CORE_PEER_LOCALMSPID="Org1MSP"
CORE_PEER_TLS_ROOTCERT_FILE=/shared/crypto-config/peerOrganizations/firstorg.com/peers/org1peer1.firstorg.com/tls/ca.crt
CHANNEL_NAME=test-channel
ORDERER_CA_TLS=/shared/crypto-config/ordererOrganizations/blockchain.com/orderers/orderer1.blockchain.com/msp/tlscacerts/tlsordererca-cert.pem

```

## Create & Join channel
``` bash
peer channel create -o orderer1:7050 -c $CHANNEL_NAME -f ./shared/channel-artifacts/test-channel.tx --tls --cafile $ORDERER_CA_TLS
peer channel join -b test-channel.block

```

## Update org1 anchor peers
``` bash
peer channel update -o orderer1:7050 -c $CHANNEL_NAME -f ./shared/channel-artifacts/test-channelOrg1MSPanchors.tx --tls --cafile $ORDERER_CA_TLS
```

## Export org1peer2 profile and join channel
``` bash
CORE_PEER_MSPCONFIGPATH=/shared/crypto-config/peerOrganizations/firstorg.com/users/Admin@firstorg.com/msp
CORE_PEER_ADDRESS=org1peer2:7051
CORE_PEER_LOCALMSPID="Org1MSP"
CORE_PEER_TLS_ROOTCERT_FILE=/shared/crypto-config/peerOrganizations/firstorg.com/peers/org1peer2.firstorg.com/tls/ca.crt
CHANNEL_NAME=test-channel
ORDERER_CA_TLS=/shared/crypto-config/ordererOrganizations/blockchain.com/orderers/orderer1.blockchain.com/msp/tlscacerts/tlsordererca-cert.pem
peer channel join -b test-channel.block

```

## Export org2peer1 profile and join channel
``` bash
CORE_PEER_MSPCONFIGPATH=/shared/crypto-config/peerOrganizations/secondorg.com/users/Admin@secondorg.com/msp
CORE_PEER_ADDRESS=org2peer1:7051
CORE_PEER_LOCALMSPID="Org2MSP"
CORE_PEER_TLS_ROOTCERT_FILE=/shared/crypto-config/peerOrganizations/secondorg.com/peers/org2peer1.secondorg.com/tls/ca.crt
CHANNEL_NAME=test-channel
ORDERER_CA_TLS=/shared/crypto-config/ordererOrganizations/blockchain.com/orderers/orderer1.blockchain.com/msp/tlscacerts/tlsordererca-cert.pem
peer channel join -b test-channel.block

```

## Update org2 anchor peers
``` bash
peer channel update -o orderer1:7050 -c $CHANNEL_NAME -f ./shared/channel-artifacts/test-channelOrg2MSPanchors.tx --tls --cafile $ORDERER_CA_TLS
```

## Export org2peer2 profile and join channel
``` bash
CORE_PEER_MSPCONFIGPATH=/shared/crypto-config/peerOrganizations/secondorg.com/users/Admin@secondorg.com/msp
CORE_PEER_ADDRESS=org2peer2:7051
CORE_PEER_LOCALMSPID="Org2MSP"
CORE_PEER_TLS_ROOTCERT_FILE=/shared/crypto-config/peerOrganizations/secondorg.com/peers/org2peer2.secondorg.com/tls/ca.crt
CHANNEL_NAME=test-channel
ORDERER_CA_TLS=/shared/crypto-config/ordererOrganizations/blockchain.com/orderers/orderer1.blockchain.com/msp/tlscacerts/tlsordererca-cert.pem
peer channel join -b test-channel.block

```

## (Optional) To fetch channel configuration
``` bash
CHANNEL_NAME=test-channel
ORDERER_CA_TLS=/shared/crypto-config/ordererOrganizations/blockchain.com/orderers/orderer1.blockchain.com/msp/tlscacerts/tlsordererca-cert.pem
peer channel fetch 0 ${CHANNEL_NAME}.block -o orderer1:7050 -c $CHANNEL_NAME --tls --cafile $ORDERER_CA_TLS

```

## Install & Instantiated chaincode
Prepare chaincode source
``` bash
#Path to the source code inside /shared folder inside chaincodeinstall pod
export CHAINCODE_PATH="chaincode/*"
mkdir -p /opt/gopath/src/github.com && cp -R /shared/${CHAINCODE_PATH} /opt/gopath/src/github.com/ && ls -lah /opt/gopath/src/github.com/

```

Export variable
``` bash
export CHANNEL_NAME="test-channel"
export CHAINCODE_NAME="mycc"
export CHAINCODE_VERSION=1
#Directory within CHAINCODE_PATH that contains the chaincode code
export CHAINCODE_FOLDER="chaincode_example02"

```

org1peer1 install chaincode
``` bash
CORE_PEER_MSPCONFIGPATH=/shared/crypto-config/peerOrganizations/firstorg.com/users/Admin@firstorg.com/msp
CORE_PEER_LOCALMSPID=Org1MSP
CORE_PEER_ADDRESS=org1peer1:7051
CORE_PEER_TLS_ROOTCERT_FILE=/shared/crypto-config/peerOrganizations/firstorg.com/peers/org1peer1.firstorg.com/tls/ca.crt
peer chaincode install -n ${CHAINCODE_NAME} -v ${CHAINCODE_VERSION} -p github.com/${CHAINCODE_FOLDER}/

```

org2peer1 install chaincode
``` bash
CORE_PEER_MSPCONFIGPATH=/shared/crypto-config/peerOrganizations/secondorg.com/users/Admin@secondorg.com/msp
CORE_PEER_LOCALMSPID=Org2MSP
CORE_PEER_ADDRESS=org2peer1:7051
CORE_PEER_TLS_ROOTCERT_FILE=/shared/crypto-config/peerOrganizations/secondorg.com/peers/org2peer1.secondorg.com/tls/ca.crt
peer chaincode install -n ${CHAINCODE_NAME} -v ${CHAINCODE_VERSION} -p github.com/${CHAINCODE_FOLDER}/

```

instantiate chaincode
``` bash
CHAINCODE_INIT_STRING="{\"Args\":[\"init\",\"a\",\"100\",\"b\",\"200\"]}"
ORDERER_CA_TLS=/shared/crypto-config/ordererOrganizations/blockchain.com/orderers/orderer1.blockchain.com/msp/tlscacerts/tlsordererca-cert.pem
CORE_PEER_MSPCONFIGPATH=/shared/crypto-config/peerOrganizations/firstorg.com/users/Admin@firstorg.com/msp
CORE_PEER_LOCALMSPID=Org1MSP
CORE_PEER_ADDRESS=org1peer1:7051
CORE_PEER_TLS_ROOTCERT_FILE=/shared/crypto-config/peerOrganizations/firstorg.com/peers/org1peer1.firstorg.com/tls/ca.crt
peer chaincode instantiate -o orderer1:7050 --tls --cafile ${ORDERER_CA_TLS} -C ${CHANNEL_NAME} -n ${CHAINCODE_NAME} -v ${CHAINCODE_VERSION} -c ${CHAINCODE_INIT_STRING} -P 'AND("Org1MSP.peer","Org2MSP.peer")'

```

## Query & Invoke

``` bash
CHANNEL_NAME=test-channel
export CHAINCODE_NAME="mycc"

```

Query
``` bash
peer chaincode query -C $CHANNEL_NAME -n $CHAINCODE_NAME -c '{"Args":["query","a"]}'

```

Export TLS cert
``` bash
RD_PEER_TLS_ROOTCERT_FILE=/shared/crypto-config/peerOrganizations/firstorg.com/peers/org1peer1.firstorg.com/tls/ca.crt
KTB_PEER_TLS_ROOTCERT_FILE=/shared/crypto-config/peerOrganizations/secondorg.com/peers/org2peer1.secondorg.com/tls/ca.crt
ORDERER_CA_TLS=/shared/crypto-config/ordererOrganizations/blockchain.com/orderers/orderer1.blockchain.com/msp/tlscacerts/tlsordererca-cert.pem

```

Invoke
``` bash
peer chaincode invoke -C $CHANNEL_NAME -o orderer1:7050 --tls true --cafile $ORDERER_CA_TLS -n $CHAINCODE_NAME --peerAddresses org1peer1:7051 --tlsRootCertFiles $RD_PEER_TLS_ROOTCERT_FILE --peerAddresses org2peer1:7051 --tlsRootCertFiles $KTB_PEER_TLS_ROOTCERT_FILE -c '{"Args":["invoke","a","b","10"]}'

```