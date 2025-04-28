pipeline {
    agent any 


    environment {
        AWS_REGION = "us-east-1"
        ECR_REGISTRY = "261303806788.dkr.ecr.us-east-1.amazonaws.com"
        ECR_REPOSITORY = "cloudflow"
        DOCKER_IMAGE_TAG = "latest"
    }

    stages {
        stage('Checkout Code') {
            steps {
                git branch: 'main', url: 'https://github.com/Eliya-shlomo/CloudFlow.git'
            }
        }

        stage('Install Dependencies') {
            steps {
                sh 'pip install -r requirements.txt'
            }
        }

        stage('Build Docker Image') {
            steps {
                sh 'docker build -t $ECR_REPOSITORY:$DOCKER_IMAGE_TAG .'
            }
        }

        stage('Login to AWS ECR') {
            steps {
                sh 'aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $ECR_REGISTRY'
            }
        }

        stage('Push Docker Image to ECR') {
            steps {
                sh 'docker push $ECR_REGISTRY/$ECR_REPOSITORY:DOCKER_IMAGE_TAG'
            }
        }
    }
}