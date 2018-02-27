echo "Running cleanup"

set +x

source ~/.bashrc

AGAVE_USER=$(cat "user_post_build.props")
AGAVE_PASSWORD=$(cat "pw_post_build.props")

if [ -f "client.bak" ]
then
  echo "Reading Client"
  myclient=$(cat "client.bak")
  echo $myclient
  clients-delete -u $AGAVE_USER -p $AGAVE_PASSWORD $myclient
fi

rm -f client.bak
rm -f user_post_build.props
rm -f pw_post_build.props

rm -f config.yml
rm -f ~/.agave/current
