pipeline {
    agent any
    
    environment {
        AWS_ACCESS_KEY_ID     = credentials('aws-sksri')
        AWS_SECRET_ACCESS_KEY = credentials('aws-sksri')
        TF_IN_AUTOMATION      = '1'
    }

    stages {
        stage('Checkout') {
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
        
        stage('Terraform Plan') {
            steps {
                dir('terraform') {
                    sh 'terraform plan -out=tfplan'
                }
            }
        }
        
        stage('Approval') {
            when {
                branch 'master'  // Approval step only for master
            }
            steps {
                input message: 'Do you want to apply this plan?'
            }
        }
        
        stage('Terraform Apply') {
            when {
                branch 'master'  // Apply step only runs on master
            }
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
