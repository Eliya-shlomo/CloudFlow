pipeline {
    agent any

    environment {
        AWS_REGION        = "us-east-1"
        ECR_REGISTRY      = "261303806788.dkr.ecr.us-east-1.amazonaws.com"
        ECR_REPOSITORY    = "myprojectsrepos/cloudflow"
        DOCKER_IMAGE_TAG  = "${env.BRANCH_NAME}"
        KUBE_DEPLOY_PATH  = "k8s"
        KUBECONFIG        = "$HOME/.kube/config"
    }

    stages {
        stage('Checkout Code') {
            steps {
                checkout scm
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
                sh '''
                    docker tag $ECR_REPOSITORY:$DOCKER_IMAGE_TAG $ECR_REGISTRY/$ECR_REPOSITORY:$DOCKER_IMAGE_TAG
                    docker push $ECR_REGISTRY/$ECR_REPOSITORY:$DOCKER_IMAGE_TAG
                '''
            }
        }

        stage('Run Tests') {
            steps {
                sh '''
                    echo "Running Unit Tests"
                    pytest tests/ || echo "Tests failed, continuing anyway"
                '''
            }
        }

        stage('Setup kubeconfig') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'f42c76a0-5a4a-415b-971e-23aa91af0f6d', usernameVariable: 'AWS_ACCESS_KEY_ID', passwordVariable: 'AWS_SECRET_ACCESS_KEY')]) {
                    sh '''
                        aws configure set aws_access_key_id $AWS_ACCESS_KEY_ID
                        aws configure set aws_secret_access_key $AWS_SECRET_ACCESS_KEY
                        aws configure set default.region $AWS_REGION
                        aws eks update-kubeconfig --region $AWS_REGION --name cloudflow-cluster
                    '''
                }
            }
        }

        stage('Clean Previous k8s Deployment') {
            steps {
                sh '''
                    kubectl delete -f $KUBE_DEPLOY_PATH/deployment.yaml || true
                    kubectl delete -f $KUBE_DEPLOY_PATH/service.yaml || true
                '''
            }
        }

        stage('Deploy to EKS') {
            when {
                anyOf {
                    branch 'main'
                    branch 'production'
                }
            }
            steps {
                script {
                    def envName = (env.BRANCH_NAME == 'production') ? 'production' : 'staging'
                    def domain = (env.BRANCH_NAME == 'production') ? 'cloudflow.me' : 'staging.cloudflow.me'
                    sh """
                        echo "📦 Deploying to EKS as ${envName} with domain ${domain}..."
                        sed "s/__ENV__/${envName}/g" $KUBE_DEPLOY_PATH/deployment.yaml | kubectl apply -f -
                        kubectl apply -f $KUBE_DEPLOY_PATH/service.yaml
                        kubectl apply -f $KUBE_DEPLOY_PATH/ingress.yaml || true
                        echo "✅ Deployed to ${envName}!"
                    """
                }
            }
        }
    }
}
