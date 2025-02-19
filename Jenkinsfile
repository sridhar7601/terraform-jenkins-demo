pipeline {
    agent any

    environment {
        GIT_BRANCH = "${env.GIT_BRANCH}"
    }

    stages {
        stage('Setup Environment') {
            steps {
                script {
                    // Determine the deployment environment based on the branch
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

        stage('Build') {
            steps {
                script {
                    echo "Building the project..."
                    sh 'npm install'
                    sh 'npm run build'
                }
            }
        }

        stage('Run Tests') {
            steps {
                script {
                    echo "Running tests..."
                    sh 'npm test'
                }
            }
        }

        stage('Deploy') {
            steps {
                script {
                    echo "Deploying application to ${env.DEPLOY_ENV} environment..."
                    if (env.DEPLOY_ENV == 'dev') {
                        sh './deploy.sh dev'
                    } else if (env.DEPLOY_ENV == 'stage') {
                        sh './deploy.sh stage'
                    } else if (env.DEPLOY_ENV == 'prod') {
                        sh './deploy.sh prod'
                    } else {
                        echo "Unknown environment, skipping deployment."
                    }
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
