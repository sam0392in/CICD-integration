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
                        dir("Charts/sam-http-server"){
                            sh '''
                                helm package --version ${env.TAG_NAME} .
                            ''' 
                        }   
                    }
                }
            }
        }

        stage("Push Helm Chart to Chartmuseum"){
            steps{
                script{
                    container("python-aws"){
                        sh '''
                            curl -L --data-binary "@sam-http-server_${env.TAG_NAME}.tgz" http://chartmuseum.samdevops.co.in/api/charts -kv
                        '''    
                    }
                }
            }
        }

        stage("Deploy to Dev namespace using argocd"){
            steps{
                script{
                    container("python-aws"){
                        sh '''APP=`kubectl get application -n argocd | awk -F \' \' \'{print $1}\'`
                        echo $APP
                        if [[ $APP == *"sam-http-server"* ]]
                        then
                           echo "sam-http-server already deployed"
                        else
                           echo "Deploying sam-http-server"
                           #kubectl apply -f argocd-deploy.yaml -n argocd
                        fi'''
                    }
                }
            }
        }        

    }
}