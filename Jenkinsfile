pipeline {
  agent any

  environment {
    IMAGE_NAME = 'gocrud/go-crud:latest'
    REMOTE = 'kali@192.168.1.39'
  }

  stages {
    stage('Build Docker Image') {
      steps {
        sh 'docker build -t $IMAGE_NAME .'
      }
    }

    stage('Push to Docker Hub') {
      steps {
        withCredentials([usernamePassword(credentialsId: 'docker-hub', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
          sh '''
            echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin
            docker push $IMAGE_NAME
          '''
        }
      }
    }

    stage('Deploy to Kali Server') {
      steps {
        sshagent(['kali-ssh']) {
          sh '''
            ssh $REMOTE '
              docker stop go-crud || true &&
              docker rm go-crud || true &&
              docker pull gocrud/go-crud:latest &&
              docker run -d --name go-crud -p 8080:3000 --env-file /home/kali/go-crud.env gocrud/go-crud:latest
            '
          '''
        }
      }
    }
  }
}
