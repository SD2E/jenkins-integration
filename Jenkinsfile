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
  def customImage

  stage('Build docker image') {
  sh "env | sort"
  echo "My branch is: ${env.ghprbSourceBranch}"
  customImage = docker.build("pipeline:${env.BUILD_ID}")
  
  // grab the branch name referenced here on the relevant
  // repos, falling back to develop if it's not found
  def xplan_dir = "xplan_api"
  def xplan_branch = "${env.ghprbSourceBranch}"
  sh 'mkdir -p ' + xplan_dir

  def sbh_dir = "synbiohub_adapter"
  def sbh_branch = "${env.ghprbSourceBranch}"
  sh 'mkdir -p ' + sbh_dir
  
  dir(xplan_dir) {
    resolveScm source: [$class: 'GitSCMSource', credentialsId: '8d892add-6d84-42f4-9ba8-21f3f3cd84f1', id: '_', remote: 'https://github.com/sd2e/xplan_api', traits: [[$class: 'jenkins.plugins.git.traits.BranchDiscoveryTrait']]], targets: [xplan_branch, 'develop']
  }

  dir(sbh_dir) {
    resolveScm source: [$class: 'GitSCMSource', credentialsId: '8d892add-6d84-42f4-9ba8-21f3f3cd84f1', id: '_', remote: 'https://github.com/sd2e/synbiohub_adapter', traits: [[$class: 'jenkins.plugins.git.traits.BranchDiscoveryTrait']]], targets: [sbh_branch, 'develop']
  }
}

// what is the uid/gid of the build user?
  // sh 'id'
    customImage.inside {
            // stage('Test inside') {
            //     sh 'ls -l /usr/local/bin'
            // }
        testCreds()
        testPython()
    }
}

def testCreds() {
    stage('Initialize Agave') {
    	echo "In stage"
    	echo "PATH = $PATH"
	withCredentials([usernamePassword(credentialsId: '4d8e06da-d728-4dcc-aa32-9e10bb8afb73',
					  passwordVariable: 'AGAVE_PASSWORD',
					  usernameVariable: 'AGAVE_USER')]) {
	    sh '/init-sd2e.sh'
        }
    }
}

def testPython() {
    stage('xplan rule30') {
        //sh 'python /xplan-rule30-end-to-end-demo.py'
    }
}
