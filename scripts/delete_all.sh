#!/bin/bash
if [ "${PWD##*/}" == "create" ]; then
	:
elif [ "${PWD##*/}" == "scripts" ]; then
	:
else
    echo "Please run the script from 'scripts' or 'scripts/create' folder"
fi

echo ""
echo "=> DELETE_ALL: Deleting organization"
./delete/delete_organization.sh $@

echo ""
echo "=> DELETE_ALL: Deleting fabric tool"
./delete/delete_fabrictool.sh $@

echo ""
echo "=> DELETE_ALL: Deleting certificate authority"
./delete/delete_ca.sh $@

echo ""
echo "=> DELETE_ALL: Deleting orderer"
./delete/delete_orderer.sh $@
