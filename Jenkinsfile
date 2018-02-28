/*
 Copied from an example: https://gist.github.com/jonico/e205b16cf07451b2f475543cf1541e70
*/

node {

  testCreds()

}


def testCreds() {
    stage('Test Credentials') {
    	echo "In stage"
	withCredentials([usernamePassword(credentialsId: '4d8e06da-d728-4dcc-aa32-9e10bb8afb73', passwordVariable: 'SD2PASS', usernameVariable: 'SD2USER')]) {
	    echo SD2USER
        }
    }
}
