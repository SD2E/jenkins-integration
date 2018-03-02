/*
 Copied from an example: https://gist.github.com/jonico/e205b16cf07451b2f475543cf1541e70
*/

node {
  checkout scm
  // withEnv(['PATH+=/var/lib/jenkins/sd2e-cloud-cli/bin']) {
  //   testCreds()
  // }
  // withPythonEnv('Python2.7') {
  //   installDeps()
  //   testPython()
  // }
  def customImage = docker.build("pipeline:${env.BUILD_ID}")

// what is the uid/gid of the build user?
  sh 'id'
    customImage.inside {
            stage('Test inside') {
                sh 'ls -l /usr/local/bin'
            }
        testCreds()
        testPython()
    }
}

def testCreds() {
    stage('Test Credentials') {
    	echo "In stage"
    	echo "PATH = $PATH"
	withCredentials([usernamePassword(credentialsId: '4d8e06da-d728-4dcc-aa32-9e10bb8afb73',
					  passwordVariable: 'AGAVE_PASSWORD',
					  usernameVariable: 'AGAVE_USER')]) {
	    sh '/init-sd2e.sh'
        }
    }
}

def installDeps() {
    stage('Install Dependencies') {
        // pysh 'pip install numpy'
        pysh 'pip install agavepy'
        pysh 'pip install git+https://github.com/SD2E/xplan_api.git'
    }
}

def testPython() {
    stage('Test Python') {
        sh 'python /xplan-rule30-end-to-end-demo.py'
    }
}
