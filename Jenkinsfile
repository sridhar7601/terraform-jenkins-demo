pipeline {
    agent any
    environment {
        AWS_ACCESS_KEY_ID     = credentials('aws-sksri')
        AWS_SECRET_ACCESS_KEY = credentials('aws-sksri')
        TF_IN_AUTOMATION      = '1'
    }
    triggers {
        pollSCM('H/5 * * * *')  // Fixed syntax error in polling schedule
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
        
        // Separate deployment workflows for stage and prod
        stage('Deploy to Stage') {
            stages {
                stage('Plan Stage') {
                    steps {
                        dir('terraform') {
                            sh 'terraform plan -var="env=stage" -out=tfplan-stage'
                        }
                    }
                }
                
                stage('Approval for Stage') {
                    steps {
                        input message: 'Do you want to apply this plan to STAGE?'
                    }
                }
                
                stage('Apply to Stage') {
                    steps {
                        dir('terraform') {
                            sh 'terraform apply -auto-approve tfplan-stage'
                        }
                    }
                }
            }
        }
        
        stage('Deploy to Prod') {
            stages {
                stage('Plan Prod') {
                    steps {
                        dir('terraform') {
                            // Create a fresh plan for prod AFTER stage deployment is complete
                            sh 'terraform plan -var="env=prod" -out=tfplan-prod'
                        }
                    }
                }
                
                stage('Approval for Prod') {
                    steps {
                        input message: 'Do you want to apply this plan to PROD?'
                    }
                }
                
                stage('Apply to Prod') {
                    steps {
                        dir('terraform') {
                            sh 'terraform apply -auto-approve tfplan-prod'
                        }
                    }
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