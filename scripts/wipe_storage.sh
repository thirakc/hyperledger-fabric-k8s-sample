#!/bin/bash
if [ "${PWD##*/}" == "create" ]; then
	:
elif [ "${PWD##*/}" == "scripts" ]; then
	:
else
    echo "Please run the script from 'scripts' or 'scripts/create' folder"
fi

echo ""
echo "=> WIPE_STORAGE: Deleting pvc and pv"
./delete/delete_storage.sh $@