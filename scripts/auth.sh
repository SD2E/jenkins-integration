set -x 
curl -L https://raw.githubusercontent.com/sd2e/sd2e-cli/master/install/install.sh | sh
source ~/.bashrc
tenants-init -t sd2e

if [ -f "client.bak" ]
then
  echo "Reading Client"
  myclient=$(cat "client.bak")
  echo $myclient
  clients-delete -u $AGAVE_USER -p $AGAVE_PASSWORD $myclient
fi

rm -f client.bak

client="sd2e_client_$BUILD_TAG"
echo "Writing Client"
echo $client > client.bak

clients-create -S -N $client -D "My client used for interacting with SD2E" -u $AGAVE_USER -p $AGAVE_PASSWORD
auth-tokens-create -S -p $AGAVE_PASSWORD
auth-check
