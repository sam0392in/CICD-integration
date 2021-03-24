pipeline {
    options {
        buildDiscarder(logRotator(numToKeepStr: '5', daysToKeepStr: '5'))
    }
    agent {
       kubernetes {
            yamlFile 'jenkins-python-aws.yaml'
        }
    }
    stages{
        stage("build and push image"){
            steps{
                script{
                    container("python-aws"){
                        sh "echo hello"
                    }
                }
            }
        }
    }
}