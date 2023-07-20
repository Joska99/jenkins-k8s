pipeline {
  agent {
    kubernetes {
      defaultContainer 'slave'
        yaml '''
        kind: Pod
        spec:
          containers:
          - name: slave-pod
          image: node
          imagePullPolicy: Always
          command:
            - "sleep"
            args:
            - "60"
        '''
    }
  }
  environment {
      IMG_NAME = 'web-k8s'
      DOCKER_REPO = 'joska99/labs-images'
  }
  stages {
    stage('test') {
      steps {
        container('slave-pod')
          script {
            sh 'node --version'
          }
      }
    }
  }
}
