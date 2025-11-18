pipeline {
    agent any

    environment {
        DOCKER_HUB_CREDENTIALS = 'docker-hub-token'  // ID للكريدنشل في Jenkins
        IMAGE_NAME = 'ahmedzain10/spring-petclinic-prod'
        IMAGE_TAG = 'V1.1'
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
                sh '''
                    command -v git >/dev/null 2>&1 || { echo "Git not installed"; exit 1; }
                    command -v mvn >/dev/null 2>&1 || { echo "Maven not installed"; exit 1; }
                    command -v docker >/dev/null 2>&1 || { echo "Docker not installed"; exit 1; }
                    command -v docker-compose >/dev/null 2>&1 || { echo "Docker Compose not installed"; exit 1; }
                    echo "All required programs are installed."
                '''
            }
        }

        stage('Run Docker Compose') {
            steps {
                sh 'docker-compose up -d --build || true'
            }
        }

        stage('Build Docker Image') {
            steps {
                sh "docker build -t ${IMAGE_NAME}:${IMAGE_TAG} ."
            }
        }

        stage('Docker Login & Push') {
            steps {
                withCredentials([usernamePassword(credentialsId: "${DOCKER_HUB_CREDENTIALS}", usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                    sh 'echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin'
                    sh "docker push ${IMAGE_NAME}:${IMAGE_TAG}"
                }
            }
        }
    }

    post {
        success {
            echo 'Pipeline completed successfully.'
        }
        failure {
            echo 'Pipeline failed.'
        }
    }
}

