pipeline {
    agent any

    environment {
        DOCKER_IMAGE = "eliya-cloudflow:latest"
    }

    stages {
        stage('Clone Repo') {
            steps {
                git branch: 'main', url: 'https://github.com/Eliya-shlomo/CloudFlow.git'
            }
        }

        stage('Install Dependencies') {
            steps {
                sh 'pip install -r requirements.txt'
            }
        }

        stage('Build Docker Image'){
            steps {
                sh 'docker build -t $DOCKER_IMAGE .'
            }
        }

        stage('Run Docker Container') {
            steps {
                sh 'docker rm -f cloudflow-app || true'
                sh 'docker run -d -p 5000:5000 --name cloudflow-app $DOCKER_IMAGE'
            }
        }
    }
}
