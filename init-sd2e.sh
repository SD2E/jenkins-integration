#!/bin/sh

# echo commands
set -x
# stop on error
set -e

# This is the location in the Docker image
export PATH=$PATH:/root/sd2e-cloud-cli/bin

tenants-init -t sd2e

client="sd2e_client_$BUILD_TAG"
echo "Writing Client"
echo $client > client.bak

clients-create -S -N $client -D "My client used for interacting with SD2E" -u $AGAVE_USER -p $AGAVE_PASSWORD
auth-tokens-create -S -p $AGAVE_PASSWORD
auth-check

# files-list
