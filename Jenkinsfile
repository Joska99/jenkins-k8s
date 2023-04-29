pipeline {
  agent any
  environment {
    IMG_NAME = 'web-k8s'
    DOCKER_REPO = 'joska99/labs-images'
    ACR_REPO = 'images4k8s.azurecr.io/images4k8s'
    DEPLOY_NAME = 'deployment.yaml'
  }
  stages {
    stage('build Docker image') {
      steps {
        script {
          sh 'docker build -t ${IMG_NAME} .'
          sh 'docker tag web-k8s ${DOCKER_REPO}:${IMG_NAME}'
        }
      }
    }
    stage('push to DcokerHub') {
      steps {
        script {
          withCredentials([usernamePassword(credentialsId: 'DockerHub-LG', passwordVariable: 'PSWD', usernameVariable: 'LOGIN')]) {
            sh 'docker login -u ${LOGIN} -p ${PSWD}'
          }
          sh 'docker push ${DOCKER_REPO}:${IMG_NAME}'
        }
      }
    }
    stage('Push to ACR') {
      steps {
        withCredentials([azureServicePrincipal('ACR_CRED')]) {
          sh 'docker login -u $AZURE_CLIENT_ID -p $AZURE_CLIENT_SECRET ${ACR_REPO}'
          sh 'docker tag ${IMG_NAME} ${ACR_REPO}:${IMG_NAME}'
          sh 'docker push ${ACR_REPO}:${IMG_NAME}'
        }
      }
    }
    stage('Deploy to AKS') {
      steps {
        withKubeConfig(caCertificate: '', clusterName: '', contextName: '', credentialsId: 'k8s-conf', namespace: '', restrictKubeConfigAccess: false, serverUrl: '') {
          sh 'kubectl apply -f ${DEPLOY_NAME}'
        }
      }
    }
  }
}
