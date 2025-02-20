pipeline {
    agent any
    environment {
        AWS_ACCESS_KEY_ID     = credentials('aws-sksri')
        AWS_SECRET_ACCESS_KEY = credentials('aws-sksri')
        TF_IN_AUTOMATION      = '1'
    }
    parameters {
        choice(name: 'ENVIRONMENT', choices: ['stage', 'prod'], description: 'Select deployment environment')
    }
    triggers {
        pollSCM('H/5 * * * *')
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
                    // Initialize with backend configuration
                    script {
                        sh """
                        terraform init \
                          -backend-config="bucket=terraform-state-storage-bucket" \
                          -backend-config="key=terraform/${params.ENVIRONMENT}/terraform.tfstate" \
                          -backend-config="region=us-east-1" \
                          -backend-config="encrypt=true"
                        """
                    }
                }
            }
        }
        
        stage('Terraform Plan') {
            steps {
                dir('terraform') {
                    sh "terraform plan -var=\"env=${params.ENVIRONMENT}\" -out=tfplan"
                }
            }
        }
        
        stage('Approval for Deployment') {
            steps {
                input message: "Do you want to apply this plan to ${params.ENVIRONMENT}?"
            }
        }
        
        stage('Terraform Apply') {
            steps {
                dir('terraform') {
                    sh "terraform apply -auto-approve tfplan"
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