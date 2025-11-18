
pipeline {
    agent any

    environment {
        IMAGE_NAME = 'ahmedzain10/spring-petclinic-prod'
        IMAGE_TAG  = "V${env.BUILD_NUMBER}"   // كل build هيبقى له تاج جديد تلقائي
        DOCKER_HUB_CREDENTIALS = 'docker-hub-token'
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

        stage('Run Docker Compose') {
            steps {
                sh '''
                docker-compose down || true
                docker-compose up -d --build
                '''
            }
        }

        stage('Build Docker Image') {
            steps {
                sh "docker build -t ${IMAGE_NAME}:${IMAGE_TAG} ."
            }
        }

        stage('Push Image to Docker Hub') {
            steps {
                withCredentials([usernamePassword(credentialsId: "${DOCKER_HUB_CREDENTIALS}", usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                    sh '''
                    echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin
                    docker push ${IMAGE_NAME}:${IMAGE_TAG}
                    '''
                }
            }
        }
    }

    post {
        success {
            echo "Pipeline completed successfully. Image tag: ${IMAGE_TAG}"
        }
        failure {
            echo 'Pipeline failed.'
        }
    }
}
