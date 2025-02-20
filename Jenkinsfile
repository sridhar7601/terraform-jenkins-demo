pipeline {
    agent any

    environment {
        AWS_ACCESS_KEY_ID     = credentials('aws-sksri')
        AWS_SECRET_ACCESS_KEY = credentials('aws-sksri')
        TF_IN_AUTOMATION      = '1'
    }

    triggers {
        pollSCM('H/5 * * * *')  // Check Git every 5 minutes for changes
    }

    stages {
        stage('Checkout Code') {
            steps {
                checkout scm
                script {
                    BRANCH_NAME = env.GIT_BRANCH
                    echo "Building on branch: ${BRANCH_NAME}"
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
        
        stage('Terraform Plan for Stage & Prod') {
            steps {
                dir('terraform') {
                    sh 'terraform plan -var="env=stage" -out=tfplan-stage'
                    sh 'terraform plan -var="env=prod" -out=tfplan-prod'
                }
            }
        }
        
        stage('Approval for Stage Deployment') {
            steps {
                input message: 'Do you want to apply this plan to STAGE?'
            }
        }
        
        stage('Deploy to Stage') {
            steps {
                dir('terraform') {
                    sh 'terraform apply -auto-approve tfplan-stage'
                }
            }
        }

        stage('Approval for Prod Deployment') {
            steps {
                input message: 'Do you want to apply this plan to PROD?'
            }
        }
        
        stage('Deploy to Prod') {
            steps {
                dir('terraform') {
                    sh 'terraform apply -auto-approve tfplan-prod'
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
