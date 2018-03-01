#!/bin/sh

# PATH is set in the Jenkinsfile
# PATH=/var/lib/jenkins/sd2e-cloud-cli/bin

set -x

tenants-init -t sd2e

client="sd2e_client_$BUILD_TAG"
echo "Writing Client"
echo $client > client.bak

clients-create -S -N $client -D "My client used for interacting with SD2E" -u $AGAVE_USER -p $AGAVE_PASSWORD
auth-tokens-create -S -p $AGAVE_PASSWORD
auth-check

# files-list
