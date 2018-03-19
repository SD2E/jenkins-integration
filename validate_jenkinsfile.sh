JENKINS_CRUMB=`curl "jenkins.sd2e.org/crumbIssuer/api/xml?xpath=concat(//crumbRequestField,\":\",//crumb)"`
curl -X POST -H $JENKINS_CRUMB -F "jenkinsfile=<Jenkinsfile" jenkins.sd2e.org/pipeline-model-converter/validate

