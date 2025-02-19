pipeline {
    agent any

    environment {
        GIT_BRANCH = "${env.GIT_BRANCH}"
    }

    stages {
        stage('Setup Environment') {
            steps {
                script {
                    env.DEPLOY_ENV = (env.GIT_BRANCH == 'feature/dev') ? 'dev' :
                                     (env.GIT_BRANCH == 'feature/stage') ? 'stage' :
                                     (env.GIT_BRANCH == 'feature/prod') ? 'prod' : 'test'

                    echo "Deploying to environment: ${env.DEPLOY_ENV}"
                }
            }
        }

        stage('Checkout Code') {
            steps {
                checkout scm
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
                    sh '''terraform plan -var="env=$DEPLOY_ENV" -var="bucket_name_prefix=terraform-demo" -out=tfplan'''
                }
            }
        }

        stage('Approval') {
            when {
                branch 'feature/prod'  // Approval only for production
            }
            steps {
                input message: 'Do you want to apply this plan?'
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
        success {
            echo "Pipeline completed successfully!"
        }
        failure {
            echo "Pipeline failed!"
        }
    }
}
