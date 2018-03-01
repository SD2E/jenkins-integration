/*
 Copied from an example: https://gist.github.com/jonico/e205b16cf07451b2f475543cf1541e70
*/

node {
  withEnv(['PATH+=/var/lib/jenkins/sd2e-cloud-cli/bin']) {
    testCreds()
  }
}

def testCreds() {
    stage('Test Credentials') {
    	echo "In stage"
    	echo "PATH = $PATH"
	withCredentials([usernamePassword(credentialsId: '4d8e06da-d728-4dcc-aa32-9e10bb8afb73',
					  passwordVariable: 'AGAVE_PASSWORD',
					  usernameVariable: 'AGAVE_USER')]) {
            echo env.BUILD_TAG
	    /* sh 'tenants-init -t sd2e' */
	    sh 'client="sd2e_client_$BUILD_TAG"'
	    sh 'clients-create -S -N $client -D "My client used for interacting with SD2E" -u $AGAVE_USER -p $AGAVE_PASSWORD'
	    sh 'auth-tokens-create -S -p $AGAVE_PASSWORD'
	    sh 'auth-check'
        }
    }
}
