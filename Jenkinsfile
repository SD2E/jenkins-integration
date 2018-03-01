/*
 Copied from an example: https://gist.github.com/jonico/e205b16cf07451b2f475543cf1541e70
*/

node {
  environment {
    PATH = "/var/lib/jenkins/sd2e-cloud-cli/bin:$PATH"
  }
  testCreds()

}


def testCreds() {
    stage('Test Credentials') {
    	echo "In stage"
    	echo "PATH = $PATH"
	withCredentials([usernamePassword(credentialsId: '4d8e06da-d728-4dcc-aa32-9e10bb8afb73', passwordVariable: 'SD2PASS', usernameVariable: 'SD2USER')]) {
	    echo SD2USER
	    sh 'files-list'
        }
    }
}
