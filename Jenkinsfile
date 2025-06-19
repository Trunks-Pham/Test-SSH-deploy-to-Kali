pipeline {
  agent any

  environment {
    IMAGE_NAME = 'phamminhthao/go-crud:latest'
    REMOTE = 'kali@192.168.1.39'
  }

  stages {
    stage('Build Docker Image') {
      steps {
        echo '📦 Building Docker image...'
        sh '''
          set -e
          docker build -t $IMAGE_NAME .
        '''
      }
    }

    stage('Push to Docker Hub') {
      steps {
        echo '🚀 Pushing image to Docker Hub...'
        withCredentials([usernamePassword(
          credentialsId: 'docker-hub',
          usernameVariable: 'DOCKER_USER',
          passwordVariable: 'DOCKER_PASS'
        )]) {
          sh '''
            set -e
            echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin
            docker push $IMAGE_NAME
          '''
        }
      }
    }

    stage('Deploy to Kali Server') {
      steps {
        echo '🚢 Deploying to Kali Linux server...'
        withCredentials([string(credentialsId: 'APP_ENV_FILE', variable: 'ENV_CONTENT')]) {
          sshagent(['kali-ssh']) {
            sh '''
              set -e

              echo "📤 Copying .env to Kali..."
              ssh -o StrictHostKeyChecking=no $REMOTE "mkdir -p /home/kali/"
              ssh $REMOTE "cat > /home/kali/go-crud.env" << EOF
              $ENV_CONTENT
EOF

              echo "🛑 Restarting container..."
              ssh $REMOTE '
                docker stop go-crud || true &&
                docker rm go-crud || true &&
                docker pull $IMAGE_NAME &&
                docker run -d --name go-crud -p 8080:3000 --env-file /home/kali/go-crud.env $IMAGE_NAME
              '
            '''
          }
        }
      }
    }
  }

  post {
    failure {
      echo '❌ Build failed. Check logs!'
    }
    success {
      echo '✅ CI/CD pipeline executed successfully!'
    }
  }
}
