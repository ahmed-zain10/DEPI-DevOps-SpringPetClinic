pipeline {

    agent {
        docker {
            image 'maven:3.9.6-eclipse-temurin-17'
            args '-v /root/.m2:/root/.m2'
        }
    }

    environment {
        IMAGE_NAME = 'ahmedzain10/spring-petclinic-prod'
        IMAGE_TAG = 'V1.1'
    }

    stages {

        stage('Checkout SCM') {
            steps {
                checkout([$class: 'GitSCM',
                    branches: [[name: '*/main']],
                    userRemoteConfigs: [[
                        url: 'https://github.com/ahmed-zain10/DEPI-DevOps-SpringPetClinic.git',
                        credentialsId: 'github-credentials'
                    ]]
                ])
            }
        }

        stage('Build with Maven') {
            steps {
                sh 'mvn -version'
                sh 'mvn clean package -DskipTests'
            }
        }

        stage('Build Docker Image') {
            steps {
                sh "docker build -t ${IMAGE_NAME}:${IMAGE_TAG} ."
            }
        }

        stage('Push Image to Docker Hub') {
            steps {
                sh "docker push ${IMAGE_NAME}:${IMAGE_TAG}"
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

