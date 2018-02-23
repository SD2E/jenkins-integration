pipeline {
  agent any

  stages {
    stage("Hello") {
      steps {
        echo "Hello"
      }
    }
    stage("Install Deps") {
        steps {
            sh returnStatus: true, script: 'pip2 install -t python2 git+https://github.com/SD2E/xplan_api.git'
        }
    }
  }
}
