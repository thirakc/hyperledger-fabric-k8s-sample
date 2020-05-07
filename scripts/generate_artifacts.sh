#!/bin/bash

set -e

ORG_SUFFIX=MSP
CHANNEL_NAME=test-channel
CONSENSUS_PROFILE=SampleMultiNodeEtcdRaft  #TwoOrgsOrdererGenesis for solo
CONSORTIUM_PROFILE=TwoOrgsChannel

export FABRIC_CFG_PATH=../artifacts-config

function generateCrypto() {
  if [ -d "../artifacts-config/crypto-config" ]; then
    rm -Rf ../artifacts-config/crypto-config
  fi
  set -x
  ../bin/cryptogen generate --config=../artifacts-config/crypto-config.yaml --output="../artifacts-config/crypto-config"
  set +x
  res=$?
  if [ $res -ne 0 ]; then
    echo "Failed to generate crypto..."
    exit 1
  fi
  echo
}

function generateGenesisBlock(){
  if [ -d "../artifacts-config/channel-artifacts" ]; then
      rm -Rf ../artifacts-config/channel-artifacts
  fi
  mkdir -p ../artifacts-config/channel-artifacts

  set -x
  ../bin/configtxgen -profile ${CONSENSUS_PROFILE} -outputBlock ../artifacts-config/channel-artifacts/genesis.block
  set +x
  res=$?
  if [ $res -ne 0 ]; then
    echo "Failed to generate genesis block..."
    exit 1
  fi
}

function generateVrtChannelTx(){
  set -x
  ../bin/configtxgen -profile ${CONSORTIUM_PROFILE} -outputCreateChannelTx ../artifacts-config/channel-artifacts/${CHANNEL_NAME}.tx -channelID ${CHANNEL_NAME}
  set +x
  res=$?
  if [ $res -ne 0 ]; then
    echo "Failed to generate channel..."
    exit 1
  fi
}

function generateAnchorsTx() {
  for orgName in Org1 Org2; do
    ANCHORS_NAME=${CHANNEL_NAME}${orgName}${ORG_SUFFIX}anchors.tx
    set -x
    ../bin/configtxgen -profile ${CONSORTIUM_PROFILE} -outputAnchorPeersUpdate ../artifacts-config/channel-artifacts/${ANCHORS_NAME} -channelID ${CHANNEL_NAME} -asOrg ${orgName}${ORG_SUFFIX}
    set +x
    res=$?
    if [ $res -ne 0 ]; then
      echo "Failed to generate anchor..."
      exit 1
    fi
    sleep 1
  done
}

function changeCaKeyName() {
  for file in $(find ../artifacts-config/crypto-config -iname *_sk); do
    dir=$(dirname $file);
    set -x
    mv ${dir}/*_sk ${dir}/key.pem;
    set +x
  done
}

echo
echo "##########################################################"
echo "#### GENERATE CRYPTO & ARTIFACTS #####"
echo "##########################################################"
generateCrypto
echo
echo "##########################################################"
echo "#### GENERATE GENESIS BLOCK #####"
echo "##########################################################"
generateGenesisBlock
echo
echo "##########################################################"
echo "#### GENERATE CHANNEL #####"
echo "##########################################################"
generateVrtChannelTx
echo
echo "##########################################################"
echo "#### GENERATE ANCHORS #####"
echo "##########################################################"
generateAnchorsTx
echo
echo "##########################################################"
echo "#### CHANGE CA KEY NAME #####"
echo "##########################################################"
changeCaKeyName