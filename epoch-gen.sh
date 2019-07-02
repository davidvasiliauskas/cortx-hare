#!/bin/bash

# Safely generates unique epoch id using Consul's CAS-put operation
# over the "epoch" key in the persistent KV-store.

get_epoch_candidate()
{
	consul kv get -detailed epoch | grep ModifyIndex | awk '{print $2}'
}

commit_new_epoch()
{
	consul kv put -cas -modify-index=$1 epoch $1 > /dev/null
}

NEW_EPOCH=`get_epoch_candidate`

while ! commit_new_epoch $NEW_EPOCH; do
	NEW_EPOCH=`get_epoch_candidate`
done

echo $NEW_EPOCH