#!/bin/bash

set -e
#if [ "${PWD##*/}" == "create" ]; then
#    CONFIG_FOLDER=${PWD}/../../artifacts-config
#elif [ "${PWD##*/}" == "scripts" ]; then
#    CONFIG_FOLDER=${PWD}/../artifacts-config
#else
#    echo "Please run the script from 'scripts' or 'scripts/create' folder"
#fi

echo ""
echo "=> CREATE_ALL: Creating storage"
create/create_storage.sh $@

echo ""
echo "=> CREATE_ALL: Running fabric-tool Pod"
create/create_fabrictool.sh $@

#echo ""
#echo "=> CREATE_ALL: Copying configuration for the network into the storage"
#kubectl cp ${CONFIG_FOLDER} utility-pod:/shared/

echo "Waiting for 5 more seconds for copying artifacts to avoid any network delay"
sleep 5

echo ""
echo "=> CREATE_ALL: Creating orderer"
create/create_orderer.sh $@

echo ""
echo "=> CREATE_ALL: Creating certificate authority"
create/create_ca.sh $@

echo ""
echo "=> CREATE_ALL: Creating organization"
create/create_organization.sh $@

echo ""
echo "=> CREATE_ALL: Join blockchain network on each node"
./join_network.sh $@

echo ""
echo "=> CREATE_ALL: Install & Instantiate chaincode"
./run_chaincode.sh

echo "Done!!"