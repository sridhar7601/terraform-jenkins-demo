pipeline {
    agent any

    environment {
        AWS_ACCESS_KEY_ID     = credentials('aws-sksri')
        AWS_SECRET_ACCESS_KEY = credentials('aws-sksri')
        TF_IN_AUTOMATION      = '1'
        ENV_NAME              = env.GIT_BRANCH == 'feature/dev' ? 'dev' :
                                env.GIT_BRANCH == 'feature/stage' ? 'stage' :
                                env.GIT_BRANCH == 'feature/prod' ? 'prod' : 'dev'
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
                script {
                    echo "Deploying to environment: ${ENV_NAME}"
                }
            }
        }

        stage('Terraform Init') {
            steps {
                dir('terraform') {
                    sh 'terraform init'
                }
            }
        }

        stage('Terraform Plan') {
            steps {
                dir('terraform') {
                    sh "terraform plan -var-file=${ENV_NAME}.tfvars -out=tfplan"
                }
            }
        }

        stage('Terraform Apply') {
            steps {
                dir('terraform') {
                    sh 'terraform apply -auto-approve tfplan'
                }
            }
        }
    }

    post {
        always {
            cleanWs()
        }
    }
}
