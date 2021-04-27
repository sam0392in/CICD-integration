@Library("sam-jenkins-libraries") _

pipeline {
  options {
    buildDiscarder(logRotator(numToKeepStr: '5', daysToKeepStr: '5'))
  }
  agent {
    label "python-agent"
  }
  environment {
    SKAFFOLD_DEFAULT_REPO = "sam0392in/sam"
    APP_NAME = "sam-http-server"
  }  
  stages{
    stage("Prepare Environment"){
      steps{
        script{
          container("python"){
            preBuild(release: "minor")
            sh "mkdir -p ~/.kube/"
            configFileProvider([configFile(fileId: 'master-kubeconfig', targetLocation: 'config')]) {
                sh """
                    cp config ~/.kube/config
                    chmod 755 ~/.kube/config
                    #kubectl get ns
                """
            }            
          }
        }
      }
    }  
    stage("build stage"){
      steps{
        script{
          container("python"){
            pythonBuild()
            createTag()
          }
        }
      }
    }
    stage("Create and push Docker Image"){
      when { branch 'master' }
      steps{
        script{
          container("python"){
            dockerBuild(skaffoldfile: "skaffold.yaml")
          }
        }
      }
    }
    stage("package application"){
      steps{
        script{
          container("python"){
            prepareHelmChart(chartDir: "Charts/sam-http-server")
          }
        }
      }
    }        
    stage("Deploy to Dev environment"){
      when { branch 'master' }
      steps{
        script{
          container("python"){
            chartName = 'Charts/${APP_NAME}/${APP_NAME}-${VERSION}.tgz'
            pushToChartMuseum(chart: chartName, chartMuseumEnv: "dev")
            argocdDeploy(chartDir: 'Charts/${APP_NAME}', argocdAppConfig: 'argocd-deploy-dev.yaml')
          }
        }
      }
    }
  }
  post {
    always {
      script {
        cleanWs()
        //Post Job stage to run always
        postBuildAlways()
      }  
    }
    success {
      script {
        //Post Job stage to run when success
        postBuildSuccess()
      }  
    }
    failure {
      script {
        ////Post Job stage to run when failure
        postBuildFailed()
      }  
    }
    // fixed {
    //   script {
    //     //Run if previous was failure and current is success
    //     inPostJobFixed()
    //   }  
    // }
  }
}