#!groovy

pipeline {

  environment {
    // grab the branch name referenced here on the relevant
    // repos, falling back to develop if it's not found   
    branch = "${env.ghprbSourceBranch}"
    xplan_dir = "xplan_api"
    sbh_dir = "synbiohub_adapter"
    xplan_sbol_dir = "xplan_to_sbol"
    ta3_dir = "ta3-api"
    external_job = "false"
    AGAVE_CACHE_DIR   = "${HOME}/credentials_cache/${JOB_BASE_NAME}"
    AGAVE_JSON_PARSER = "jq"
    AGAVE_TENANTID    = "sd2e"
    AGAVE_APISERVER   = "https://api.sd2e.org"
    AGAVE_USERNAME    = "sd2etest"
    AGAVE_PASSWORD    = credentials('sd2etest-tacc-password')
    PATH = "${HOME}/bin:${HOME}/sd2e-cloud-cli/bin:${env.PATH}"
  }

  agent any

  stages {
    stage('Checkout') {
      steps {
        checkout scm
      }
    }

    stage('Create Oauth client') {
      steps {
        sh "make-session-client ${JOB_BASE_NAME} ${JOB_BASE_NAME}-${BUILD_ID}"
      }
    }
    // does this branch exist in the integration-test repo?
    stage('Check integration test') {
      steps {
        script {
          try {
            echo "My external job branch is: ${external_job_branch}"
            // override the branch
            branch = "${env.external_job_branch}"
          } catch(MissingPropertyException mpe) {
            echo "No external job branch, checking repository for jenkins-integration"
            repo = "${ghprbGhRepository}"
            echo repo
            if(repo != "SD2E/jenkins-integration") {
              echo "We are not the jenkins-integration repo, launching the integration job manually"
              
              // does the branch exist?
              mySCM = resolveScm(source: [$class: 'GitSCMSource', credentialsId: '8d892add-6d84-42f4-9ba8-21f3f3cd84f1', id: '_', remote: 'https://github.com/sd2e/jenkins-integration', traits: [[$class: 'jenkins.plugins.git.traits.BranchDiscoveryTrait']]], targets: [branch, 'master'])
              def branchName = mySCM.getBranches().get(0).getName()
              if(branchName == "master") {
                //could not find a matching branch, manually launch the job
                external_job = "true"
                build job: "jenkins-integration", wait: false, parameters: [
                [$class: 'StringParameterValue', name: 'external_job_branch', value: branch]]
              } else {
                echo "Matching branch found on jenkins-integration repo, moving on"
                external_job = "true"
              }
            } else {
              echo "We are the jenkins-integration repo, moving on"
            }
          }
        }
      }
    }
    stage('Resolve SCM') {
      steps {

        script {
          if (external_job == "true") {
            echo "External job called, we're done"
            return
          }
        }

        sh "env | sort"
        echo "My branch is: ${env.ghprbSourceBranch}"
    
        sh 'mkdir -p ' + xplan_dir
        sh 'mkdir -p ' + sbh_dir
        sh 'mkdir -p ' + ta3_dir
        sh 'mkdir -p ' + xplan_sbol_dir
    
        // change yg when merged
        dir(xplan_dir) {
          checkout resolveScm(source: [$class: 'GitSCMSource', credentialsId: '8d892add-6d84-42f4-9ba8-21f3f3cd84f1', id: '_', remote: 'https://github.com/sd2e/xplan_api', traits: [[$class: 'jenkins.plugins.git.traits.BranchDiscoveryTrait']]], targets: [branch, 'develop'])
        }

        dir(sbh_dir) {
          checkout resolveScm(source: [$class: 'GitSCMSource', credentialsId: '8d892add-6d84-42f4-9ba8-21f3f3cd84f1', id: '_', remote: 'https://github.com/sd2e/synbiohub_adapter', traits: [[$class: 'jenkins.plugins.git.traits.BranchDiscoveryTrait']]], targets: [branch, 'master'])
        }

        dir(xplan_sbol_dir) {
          checkout resolveScm(source: [$class: 'GitSCMSource', credentialsId: '8d892add-6d84-42f4-9ba8-21f3f3cd84f1', id: '_', remote: 'https://github.com/SD2E/xplan_to_sbol', traits: [[$class: 'jenkins.plugins.git.traits.BranchDiscoveryTrait']]], targets: [branch, 'master'])
        }

        dir(ta3_dir) {
          checkout resolveScm(source: [$class: 'GitSCMSource', credentialsId: 'c959426e-e0cc-4d0f-aca2-3bd586e56b56', id: '_', remote: 'git@gitlab.sd2e.org:sd2program/ta3-api.git', traits: [[$class: 'jenkins.plugins.git.traits.BranchDiscoveryTrait']]], targets: [branch, 'develop'])
        }
      }
    }
  
    stage('Copy test data') {
      steps {
        sh "ta3-api/src/util/get_rule_30_data.sh"
        sh "ta3-api/src/util/get_yeastgates_ginkgo_data.sh"
      }
    }
    stage('Build docker image') {
      steps {
        script {
          docker.build("pipeline:${env.BUILD_ID}")
        }
      }
    }
    stage('Run docker image') {
      steps {
        script {
          sh "docker run -v \$(pwd)/xplan_api:/xplan_api -v \$(pwd)/ta3-api:/ta3-api -v \$(pwd)/xplan_to_sbol:/xplan_to_sbol -v \$(pwd)/synbiohub_adapter:/synbiohub_adapter pipeline:${env.BUILD_ID}"
        }
      }
    }
  }
  post {
    always {
      archiveArtifacts artifacts: '$(pwd)/xplan_api/*.json', fingerprint: true, onlyIfSuccessful: true
      sh "delete-session-client ${JOB_BASE_NAME} ${JOB_BASE_NAME}-${BUILD_ID}"
      cleanWs()
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
