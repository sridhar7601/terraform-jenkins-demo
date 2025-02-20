pipeline {
    agent any
    environment {
        AWS_ACCESS_KEY_ID     = credentials('aws-sksri')
        AWS_SECRET_ACCESS_KEY = credentials('aws-sksri')
        TF_IN_AUTOMATION      = '1'
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
        stage('Verify AWS Credentials') {
           steps {
                 sh 'aws sts get-caller-identity'
            }
        }
        stage('Terraform Setup') {
            steps {
                dir('terraform') {
                    script {
                        if (!fileExists('backend.tf')) {
                            writeFile file: 'backend.tf', text: '''
provider "aws" {
  region = "us-west-2"
}

terraform {
  backend "s3" {
    bucket = "terraform-state-jenkins-sksri"
    key    = "jenkins-pipeline/terraform.tfstate"
    region = "us-west-2"
    dynamodb_table = "terraform-locks"
  }
}
'''
                            sh '''
                            if ! aws s3 ls s3://terraform-state-jenkins-sksri 2>&1 > /dev/null; then
                                echo "Creating Terraform state bucket..."
                                aws s3 mb s3://terraform-state-jenkins-sksri
                                aws s3api put-bucket-versioning --bucket terraform-state-jenkins-sksri --versioning-configuration Status=Enabled
                                
                                echo "Creating DynamoDB table for state locking..."
                                aws dynamodb create-table \
                                    --table-name terraform-locks \
                                    --attribute-definitions AttributeName=LockID,AttributeType=S \
                                    --key-schema AttributeName=LockID,KeyType=HASH \
                                    --billing-mode PAY_PER_REQUEST
                                
                                aws dynamodb wait table-exists --table-name terraform-locks
                            else
                                echo "Terraform state bucket already exists"
                            fi
                            '''
                        }
                    }
                }
            }
        }
        
        stage('Initialize Terraform') {
            steps {
                dir('terraform') {
                    sh 'terraform init -reconfigure'
                }
            }
        }
        
        stage('Deploy to Stage') {
            steps {
                dir('terraform') {
                    sh 'terraform workspace select stage || terraform workspace new stage'
                    sh 'terraform plan -var="env=stage" -out=tfplan-stage'
                    stash includes: 'tfplan-stage', name: 'terraform-plan-stage'
                    sh 'terraform apply -auto-approve tfplan-stage'
                }
            }
        }
        
        stage('Approval for Production') {
            steps {
                input message: "Deploy to Production?"
            }
        }
        
        stage('Deploy to Production') {
            steps {
                dir('terraform') {
                    sh 'terraform workspace select prod || terraform workspace new prod'
                    sh 'terraform plan -var="env=prod" -out=tfplan-prod'
                    stash includes: 'tfplan-prod', name: 'terraform-plan-prod'
                    sh 'terraform apply -auto-approve tfplan-prod'
                }
            }
        }
    }
    post {
        always {
            cleanWs()
        }
        success {
            echo "Deployment completed successfully"
        }
        failure {
            echo "Deployment failed"
        }
    }
}
