def get_new_tag(latest_tag){
    latest_tag = sh "git describe --tags `git rev-list --tags --max-count=1`"
    new_tag = latest_tag + 0.01
    return new_tag
}

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
                        if (env.BRANCH_NAME == "master"){
                            sh "python3 -m compileall -l ."
                        }
                        else{
                            echo "This is PR branch, Only build will take place"
                        }
                    }
                }
            }
        }
        stage("Tag latest version"){
            when { branch 'master' }
            steps{
                script{
                    container("python-aws"){
                        new_tag = get_new_tag()
                        sh '''
                            ${GIT_COMMIT}
                            git tag -a ${new_tag} ${GIT_COMMIT}
                        '''
                    }
                }
            }
        }
        stage("Create and push Docker Image"){
            when { branch 'master' }
            steps{
                script{
                    container("python-aws"){
                        sh '''
                            docker build -t sam0392in/sam:sam-http-server_${new_tag} .
                            docker push sam0392in/sam:sam-http-server_${new_tag}
                        '''
                    }
                }
            }
        }

        stage("Package application"){
            when { branch 'master' }
            steps{
                script{
                    container("python-aws"){
                        dir("Charts/sam-http-server"){
                            sh '''
                                helm package --version ${new_tag} .
                            '''
                        }
                    }
                }
            }
        }

        stage("Push Helm Chart to Chartmuseum"){
            when { branch 'master' }
            steps{
                script{
                    container("python-aws"){
                        sh '''
                            curl -L --data-binary "@sam-http-server_${new_tag}.tgz" http://chartmuseum-svc.chartmuseum:8080/api/charts -kv
                        '''
                    }
                }
            }
        }

        stage("Deploy to Dev namespace using argocd"){
            when { branch 'master' }
            steps{
                script{
                    container("python-aws"){
                        sh '''
                            APP=`kubectl get application -n argocd | awk -F \' \' \'{print $1}\'`
                            echo $APP
                            if [[ $APP == *"sam-http-server"* ]]
                            then
                               echo "sam-http-server already deployed"
                            else
                               echo "Deploying sam-http-server"
                               kubectl apply -f Charts/sam-http-server/argocdapp.yaml -n argocd
                            fi
                        '''
                    }
                }
            }
        }
    }
}