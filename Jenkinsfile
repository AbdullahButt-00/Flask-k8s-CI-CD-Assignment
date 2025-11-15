pipeline {
  agent any
  environment {

    IMAGE_NAME = 'flask-k8s-app'
    IMAGE_TAG = 'latest'
    KUBE_CONFIG = '$HOME/.kube/config'

  }

  stages {

    stage('Build Docker Image') {
      steps {

            echo "Building Docker Image..."
            sh  """
                docker build -t ${IMAGE_NAME}:${IMAGE_TAG} .
                """
      }
    }

    stage('Kubernetes Deployment') {
      steps {

            echo "Deploying to Kubernetes..."
            sh  """
                kubectl apply -f kubernetes/deployment.yaml
                kubectl apply -f kubernetes/service.yaml
                """

      }
    }

    stage('Deployment Verification') {
      steps {

            echo "Verifying Deployment..."
            sh  """
                kubectl rollout status deployment/flask-app
                kubectl get pods -o wide
                kubectl get svc -o wide
                """

      }
    }

  }
}
