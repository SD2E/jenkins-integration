pipeline {
  agent any

  stages {
    stage("Clean First") {
      steps {
        sh 'rm -rf python2'
      }
    }
    stage("Install Deps") {
        steps {
	    // Why doesn't numpy get installed by pyDOE (by xplan_api)?
	    sh 'pip2 install -t python2 agavepy numpy'
            sh 'pip2 install -t python2 git+https://github.com/SD2E/xplan_api.git'
        }
    }
    stage("Run script") {
        steps {
	    sh 'ls python2'
	    sh 'ls python2/numpy'
            sh 'PYTHONPATH=`pwd`/python2 python2 xplan-rule30-end-to-end-demo.py'
        }
    }
  }
}
