#!groovy

pipeline {

  environment {
    // grab the branch name referenced here on the relevant
    // repos, falling back to develop if it's not found   
    branch = "${env.ghprbSourceBranch}"
    xplan_dir = "xplan_api"
    sbh_dir = "synbiohub_adapter"
  }

  agent any

  stages {
    stage('Checkout') {
      steps {
        checkout scm
      }
    }

    stage('Build docker image') {
      steps {
        sh "env | sort"
        echo "My branch is: ${env.ghprbSourceBranch}"
    
        sh 'mkdir -p ' + xplan_dir
        sh 'mkdir -p ' + sbh_dir
    
        // change yg when merged
        dir(xplan_dir) {
          checkout resolveScm(source: [$class: 'GitSCMSource', credentialsId: '8d892add-6d84-42f4-9ba8-21f3f3cd84f1', id: '_', remote: 'https://github.com/sd2e/xplan_api', traits: [[$class: 'jenkins.plugins.git.traits.BranchDiscoveryTrait']]], targets: [branch, 'yg-fix', 'develop'])
        }

        dir(sbh_dir) {
          checkout resolveScm(source: [$class: 'GitSCMSource', credentialsId: '8d892add-6d84-42f4-9ba8-21f3f3cd84f1', id: '_', remote: 'https://github.com/sd2e/synbiohub_adapter', traits: [[$class: 'jenkins.plugins.git.traits.BranchDiscoveryTrait']]], targets: [branch, 'master'])
        }
        
        script {
          docker.build("pipeline:${env.BUILD_ID}", "--no-cache .")
        }
      }
    }

    stage('Test docker image') {
      steps {
        echo "nothing here yet"
        //customImage.inside {
        //testCreds()
        //testPython()
        //}
      }
    }
  }
}

def testCreds() {
  withCredentials([usernamePassword(credentialsId: '4d8e06da-d728-4dcc-aa32-9e10bb8afb73',
    passwordVariable: 'AGAVE_PASSWORD',
    usernameVariable: 'AGAVE_USER')]) {
      sh '/init-sd2e.sh'
  }
}

def testPython() {
  //sh 'python /xplan-rule30-end-to-end-demo.py'
}
