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
  }  
  stages{
    stage("build stage"){
      steps{
        script{
          container("python-aws"){
            pythonBuild()
            createTag(release: "minor")
          }
        }
      }
    }
    stage("Create and push Docker Image"){
      when { branch 'master' }
      steps{
        script{
          container("python-aws"){
            dockerBuild(skaffoldfile: "skaffold.yaml")
          }
        }
      }
    }
    stage("package application"){
      steps{
        script{
          container("python-aws"){
            prepareHelmChart(chartDir: "Charts/sam-http-server")
          }
        }
      }
    }        
    stage("Deploy to Dev environment"){
      when { branch 'master' }
      steps{
        script{
          container("python-aws"){
            chartName = sh "ls | grep -i *.tgz"
            pushToChartMuseumw(chart: chartName, chartMuseumEnv: "dev")
            argocdDeploy(chartDir: "Charts/sam-http-server", argocdAppConfig: "argocdapp.yaml")
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