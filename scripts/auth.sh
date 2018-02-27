set -x 
curl -L https://raw.githubusercontent.com/sd2e/sd2e-cli/master/install/install.sh | sh
source ~/.bashrc
tenants-init -t sd2e

client="sd2e_client_$BUILD_TAG"
echo "Writing Client"
echo $client > client.bak

clients-create -S -N $client -D "My client used for interacting with SD2E" -u $AGAVE_USER -p $AGAVE_PASSWORD
auth-tokens-create -S -p $AGAVE_PASSWORD
auth-check

echo $AGAVE_USER > user_post_build.props
echo $AGAVE_PASSWORD > pw_post_build.props
