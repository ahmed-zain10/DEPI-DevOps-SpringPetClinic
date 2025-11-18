pipeline {
    agent any

    environment {
        DOCKER_IMAGE = "ahmedzain10/spring-petclinic-prod"
        DOCKER_TAG = "V1.1"
    }

    stages {

        stage('Checkout SCM') {
            steps {
                checkout([$class: 'GitSCM',
                    branches: [[name: '*/main']],
                    doGenerateSubmoduleConfigurations: false,
                    extensions: [],
                    userRemoteConfigs: [[
                        url: 'https://github.com/ahmed-zain10/DEPI-DevOps-SpringPetClinic.git',
                        credentialsId: 'github-credentials'
                    ]]
                ])
            }
        }

        stage('Check Required Programs') {
            steps {
                echo 'Checking required programs...'
                sh '''
                    command -v git >/dev/null 2>&1 || { echo "Git not installed"; exit 1; }
                    command -v docker >/dev/null 2>&1 || { echo "Docker not installed"; exit 1; }
                    command -v docker-compose >/dev/null 2>&1 || { echo "Docker Compose not installed"; exit 1; }
                    echo "All required programs are installed."
                '''
            }
        }

        stage('Run Docker Compose') {
            steps {
                echo 'Starting Docker Compose services...'
                sh 'docker-compose up -d --build'
            }
        }

        stage('Build Docker Image') {
            steps {
                echo 'Building Docker image...'
                sh """
                    docker build -t ${DOCKER_IMAGE}:${DOCKER_TAG} .
                """
            }
        }

        stage('Push Docker Image') {
            steps {
                echo 'Pushing Docker image to Docker Hub...'
                sh """
                    docker push ${DOCKER_IMAGE}:${DOCKER_TAG}
                """
            }
        }
    }

    post {
        always {
            echo 'Pipeline finished.'
        }
        failure {
            echo 'Pipeline failed.'
        }
        success {
            echo 'Pipeline completed successfully.'
        }
    }
}

