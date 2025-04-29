pipeline {
    agent any

    environment {
        AWS_REGION        = "us-east-1"
        ECR_REGISTRY      = "261303806788.dkr.ecr.us-east-1.amazonaws.com"
        ECR_REPOSITORY    = "cloudflow"
        DOCKER_IMAGE_TAG  = "latest"
        KUBE_DEPLOY_PATH  = "k8s"
        KUBECONFIG        = "$HOME/.kube/config"
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
                withCredentials([usernamePassword(credentialsId: 'f42c76a0-5a4a-415b-971e-23aa91af0f6d', usernameVariable: 'AWS_ACCESS_KEY_ID', passwordVariable: 'AWS_SECRET_ACCESS_KEY')]) {
                    sh '''
                        aws configure set aws_access_key_id $AWS_ACCESS_KEY_ID
                        aws configure set aws_secret_access_key $AWS_SECRET_ACCESS_KEY
                        aws configure set default.region $AWS_REGION
                        aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $ECR_REGISTRY
                    '''
                }
            }
        }

        stage('Push Docker Image to ECR') {
            steps {
                sh 'docker tag $ECR_REPOSITORY:$DOCKER_IMAGE_TAG $ECR_REGISTRY/$ECR_REPOSITORY:$DOCKER_IMAGE_TAG'
                sh 'docker push $ECR_REGISTRY/$ECR_REPOSITORY:$DOCKER_IMAGE_TAG'
            }
        }

        stage('Deploy to EKS') {
            steps {
                sh '''
                    echo "📦 Deploying to EKS..."
                    kubectl apply -f $KUBE_DEPLOY_PATH/deployment.yaml
                    kubectl apply -f $KUBE_DEPLOY_PATH/service.yaml
                    echo "✅ Deployed!"
                '''
            }
        }
    }
}
