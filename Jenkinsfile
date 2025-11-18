pipeline {
    agent any

    environment {
        DOCKER_IMAGE = "ahmedzain10/spring-petclinic-prod"
        DOCKER_TAG = "V1.1" // النسخة الجديدة
    }

    stages {
        stage('Check Required Programs') {
            steps {
                echo "Checking required programs..."
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
                echo "Running Docker Compose..."
                sh '''
                    docker-compose down --remove-orphans || true
                    docker-compose up -d
                '''
            }
        }

        stage('Build Docker Image') {
            steps {
                echo "Building new Docker image ${DOCKER_IMAGE}:${DOCKER_TAG}..."
                sh '''
                    docker build -t ${DOCKER_IMAGE}:${DOCKER_TAG} -t ${DOCKER_IMAGE}:latest .
                '''
            }
        }

        stage('Push Docker Image') {
            steps {
                echo "Pushing Docker image to Docker Hub..."
                sh '''
                    docker push ${DOCKER_IMAGE}:${DOCKER_TAG}
                    docker push ${DOCKER_IMAGE}:latest
                '''
            }
        }
    }
}

