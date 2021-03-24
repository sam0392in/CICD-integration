pipeline {
    options {
        buildDiscarder(logRotator(numToKeepStr: '90', daysToKeepStr: '90'))
    }
    agent {
       kubernetes {
            yamlFile 'jenkins-python-aws.yaml'
        }
    }
    stages{

        stage("Build the project"){
            steps{
                container('python-aws'){
                    sh '''
                        pip3 install -r requirements.txt
                        python3 -m py_compile app.py
                    '''
                }
            }
        }

        stage("Create image and push to repo"){
            steps{
                container('python-aws'){
                    sh '''
                        docker build -t sam0392in/sam:http_${env.GIT_COMMIT}
                        docker push sam0392in/sam:http_${env.GIT_COMMIT}
                    '''
                }
            }
        }

        stage("Package application"){
            steps{
                container('python-aws'){
                    // def text = readFile "Charts/sam-http-server/Chart.yaml"
                    // text.replaceAll("version:*", "version: ${env.GIT_COMMIT}")
                    // text.replaceAll("appVersion:*", "appVersion: ${env.GIT_COMMIT}")
                    sh '''
                        helm package .
                    '''
                }
            }
        }

        stage("push the chart to chartmuseum"){
            steps{
                container('python-aws'){
                    sh '''
                        curl -L --data-binary "@sam-http-server-${env.GIT_COMMIT}.tgz" http://chartmuseum.samdevops.co.in/api/charts -kv
                    '''
                }
            }
        }

        stage("Deploy to cluster"){
            steps{
                container('python-aws'){
                    sh '''
                       helm pull sam-http-server-${env.GIT_COMMIT}.tgz
                       tar -xvf sam-http-server-${env.GIT_COMMIT}.tgz
                       cd sam-http-server-${env.GIT_COMMIT}
                       helm install sam-http-server -n webapp .
                    '''
                }
            }
        }
    }
}
