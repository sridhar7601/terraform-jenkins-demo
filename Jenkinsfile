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
    parameters {
        choice(name: 'ENVIRONMENT', choices: ['stage', 'prod'], description: 'Deployment environment')
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
        
        stage('Terraform Setup') {
            steps {
                dir('terraform') {
                    script {
                        // Create backend config if it doesn't exist
                        if (!fileExists('backend.tf')) {
                            writeFile file: 'backend.tf', text: '''
provider "aws" {
  region = "us-east-1"
}

terraform {
  backend "s3" {
    bucket = "terraform-state-jenkins-sksri"
    key    = "jenkins-pipeline/terraform.tfstate"
    region = "us-east-1"
    dynamodb_table = "terraform-locks"
  }
}
'''
                            // Create the state bucket and DynamoDB table if they don't exist
                            sh '''
                            # Check if state bucket exists
                            if ! aws s3 ls s3://terraform-state-jenkins-sksri 2>&1 > /dev/null; then
                                echo "Creating Terraform state bucket..."
                                aws s3 mb s3://terraform-state-jenkins-sksri
                                aws s3api put-bucket-versioning --bucket terraform-state-jenkins-sksri --versioning-configuration Status=Enabled
                                
                                # Create DynamoDB table for state locking
                                echo "Creating DynamoDB table for state locking..."
                                aws dynamodb create-table \
                                    --table-name terraform-locks \
                                    --attribute-definitions AttributeName=LockID,AttributeType=S \
                                    --key-schema AttributeName=LockID,KeyType=HASH \
                                    --billing-mode PAY_PER_REQUEST
                                
                                # Wait for DynamoDB table to be active
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
                    // Use -reconfigure to handle workspace changes
                    sh 'terraform init -reconfigure'
                    
                    // Create/select workspace for environment
                    sh "terraform workspace select ${params.ENVIRONMENT} || terraform workspace new ${params.ENVIRONMENT}"
                }
            }
        }
        
        stage('Plan Changes') {
            steps {
                dir('terraform') {
                    sh "terraform plan -var=\"env=${params.ENVIRONMENT}\" -out=tfplan"
                    
                    // Archive the plan file
                    stash includes: 'tfplan', name: 'terraform-plan'
                }
            }
        }
        
        stage('Approval') {
            steps {
                input message: "Do you want to apply this plan to ${params.ENVIRONMENT}?"
            }
        }
        
        stage('Apply Changes') {
            steps {
                dir('terraform') {
                    // Retrieve the plan file
                    unstash 'terraform-plan'
                    
                    sh 'terraform apply -auto-approve tfplan'
                    
                    // Save output variables to a file
                    sh 'terraform output -json > terraform_outputs.json'
                    archiveArtifacts artifacts: 'terraform_outputs.json', allowEmptyArchive: true
                }
            }
        }
    }
    post {
        always {
            cleanWs()
        }
        success {
            echo "Deployment to ${params.ENVIRONMENT} completed successfully"
        }
        failure {
            echo "Deployment to ${params.ENVIRONMENT} failed"
        }
    }
}