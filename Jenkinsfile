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
        
        stage("build python application"){
            steps{
                script{
                    container("python-aws"){
                        sh "python3 -m compileall -l ."
                    }
                }
            }
        }

        stage("Create and push Docker Image"){
            steps{
                script{
                    container("python-aws"){
                        sh '''
                            docker build -t sam0392in/sam:sam-http-server_${env.TAG_NAME}
                            docker push sam0392in/sam:sam-http-server_${env.TAG_NAME}
                        '''    
                    }
                }
            }
        }

        stage("Package application"){
            steps{
                script{
                    container("python-aws"){
                        sh '''
                            
                        '''    
                    }
                }
            }
        }

    }
}