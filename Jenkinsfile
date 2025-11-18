pipeline {
    agent any

    environment {
        DOCKER_IMAGE = "ahmedzain10/spring-petclinic-prod"
        SSH_HOST = "your.ubuntu.host.ip"
        SSH_USER = "ubuntu_user"
        REMOTE_APP_DIR = "/opt/petclinic-app"
    }

    stages {
        stage('1. Build and Test') {
            agent {
                docker { 
                    image 'maven:3.9.2-eclipse-temurin-17' 
                    args '-v $HOME/.m2:/root/.m2' // Cache Maven dependencies
                }
            }
            steps {
                echo 'Building Spring PetClinic application with Maven...'
                checkout scm
                sh 'mvn clean package -DskipTests'
            }
        }

        stage('2. Docker Build and Push') {
            steps {
                echo 'Building and pushing Docker image to Docker Hub...'
                withCredentials([usernamePassword(credentialsId: 'docker-hub-credentials', 
                                                  usernameVariable: 'DOCKER_USR', 
                                                  passwordVariable: 'DOCKER_PWD')]) {
                    sh "docker login -u ${DOCKER_USR} -p ${DOCKER_PWD}"
                }
                sh "docker build -t ${DOCKER_IMAGE}:V1.0 -t ${DOCKER_IMAGE}:latest ."
                sh "docker push ${DOCKER_IMAGE}:V1.0"
                sh "docker push ${DOCKER_IMAGE}:latest"
            }
        }

        stage('3. Deploy via SSH') {
            steps {
                echo "Deploying to ${SSH_USER}@${SSH_HOST} at ${REMOTE_APP_DIR}"
                withCredentials([sshUserPrivateKey(credentialsId: 'deployment-ssh-key', keyFileVariable: 'SSH_KEY_FILE')]) {
                    sh "scp -i ${SSH_KEY_FILE} -o StrictHostKeyChecking=no docker-compose.yml ${SSH_USER}@${SSH_HOST}:${REMOTE_APP_DIR}/docker-compose.yml"
                    sh """
                        ssh -i ${SSH_KEY_FILE} -o StrictHostKeyChecking=no ${SSH_USER}@${SSH_HOST} << EOF
                        cd ${REMOTE_APP_DIR}
                        docker compose pull
                        docker compose up -d --remove-orphans
                        echo "Deployment successful for Spring PetClinic."
                        EOF
                    """
                }
            }
        }
    }
}

