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
	    sh 'pip2 install agavepy'
            sh 'pip2 install -t python2 git+https://github.com/SD2E/xplan_api.git'
        }
    }
    stage("Run script") {
        steps {
            sh 'PYTHONPATH=`pwd`/python2 python2 xplan-rule30-end-to-end-demo.py'
        }
    }
  }
}
