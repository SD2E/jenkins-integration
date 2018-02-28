pipeline {
  agent any

  stages {
    stage("Clean First") {
      steps {
        sh 'rm -rf python2'
      }
    }
    stage("Install Deps") {
      withCredentials([usernamePassword(credentialsId: '4d8e06da-d728-4dcc-aa32-9e10bb8afb73', usernameVariable: 'SD2USER', passwordVariable: 'SD2PASS')]) {
        steps {
	    echo SD2USER
	    // Why doesn't numpy get installed by pyDOE (by xplan_api)?
	    sh 'pip2 install --no-cache-dir -t python2 agavepy numpy --upgrade'
            sh 'pip2 install --no-cache-dir -t python2 git+https://github.com/SD2E/xplan_api.git'
        }
      }
    }
    stage("Run script") {
        steps {
            sh 'PYTHONPATH=`pwd`/python2 python2 xplan-rule30-end-to-end-demo.py'
        }
    }
  }
}
