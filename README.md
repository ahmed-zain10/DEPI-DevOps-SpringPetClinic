#  DEPI DevOps Track: Automation for Spring PetClinic

##  Project Overview

This repository showcases a comprehensive, full-stack DevOps pipeline for the **Spring PetClinic** application, a standard web system used for managing veterinary clinic operations.

This project is a **mandatory deliverable** for the **Digital Egypt Pioneers Initiative (DEPI) – DevOps Track**.

### Application Significance
The Spring PetClinic app is an excellent DevOps candidate because it includes:

- **User Interface (UI):** User interaction layer  
- **Service Layer:** Business logic  
- **Persistence Layer:** External PostgreSQL database  

---

## 🗺️ Planned DevOps Roadmap

This project aims to implement **Continuous Integration, Delivery, and Monitoring (CI/CD/CM)** using industry tools.

| Phase | Core Tool | Objective |
|-------|-----------|-----------|
| **Containerization** | Docker | Build optimized multi-stage Docker images |
| **Local Environment** | Docker Compose | Run the full environment (App + DB) locally |
| **Infrastructure as Code (IaC)** | Terraform & AWS | Define and provision cloud infrastructure |
| **Configuration Mgmt.** | Ansible | Automate setup and configuration of hosts |
| **Automation** | Jenkins | CI/CD pipeline for build, push, deploy |
| **Orchestration** | Kubernetes (K8s) | Scalable & highly available deployment |
| **Monitoring** | Prometheus & Grafana | Metrics collection & dashboard visualization |

---

##  Current State: Production-Ready Deployment ✅

The complete DevOps pipeline is implemented and operational:
- ✅ **Docker**: Multi-stage builds with optimized images on Docker Hub
- ✅ **CI/CD**: Automated Jenkins pipeline with GitHub webhooks  
- ✅ **Kubernetes**: Production deployment with auto-scaling and high availability
- ✅ **IaC**: Terraform configurations for AWS cloud infrastructure

---

## 1️⃣ The Dockerfile

Using an optimized **multi-stage build** to minimize final image size with a lightweight JRE runtime image.

```Dockerfile
# --- STAGE 1: Build ---
# Use a Maven image to build the application .jar file
FROM maven:3.8.5-openjdk-17 AS builder

# Set the working directory
WORKDIR /app

# Copy the pom.xml and download dependencies (for caching)
COPY pom.xml .
RUN mvn dependency:go-offline

# Copy the source code and build the application
COPY src ./src
RUN mvn clean package -DskipTests

# --- STAGE 2: Run ---
# Use a minimal JRE image for the final container (lightweight and secure)
FROM eclipse-temurin:17-jre-alpine

# Set the working directory
WORKDIR /app

# Copy the built .jar file from the 'builder' stage, renaming it to app.jar
COPY --from=builder /app/target/*.jar app.jar

# Expose the port the application runs on
EXPOSE 8080

# Set the command to run the application
ENTRYPOINT ["java", "-jar", "app.jar"]
```


2️⃣ Docker Compose Configuration
Defines the PostgreSQL database + Spring PetClinic application using the latest image from Docker Hub.

docker-compose.yml
```
services:
  # 1. PostgreSQL Database Service
  db:
    image: postgres:14-alpine
    container_name: petclinic_db_container
    restart: always
    environment:
      POSTGRES_DB: petclinic_db
      POSTGRES_USER: petuser
      POSTGRES_PASSWORD: petpassword_secure
    volumes:
      - postgres_data:/var/lib/postgresql/data
    ports:
      - "5432:5432"

  # 2. Spring Boot Application Service
  app:
    image: ahmedzain10/spring-petclinic-prod:latest
    container_name: spring_petclinic_app
    restart: always
    ports:
      - "8080:8080"
    environment:
      SPRING_DATASOURCE_URL: jdbc:postgresql://db:5432/petclinic_db
      SPRING_DATASOURCE_USERNAME: petuser
      SPRING_DATASOURCE_PASSWORD: petpassword_secure
      SPRING_PROFILES_ACTIVE: postgres
    depends_on:
      - db

volumes:
  postgres_data:


```

3️⃣ Running the Environment
Start the PostgreSQL database + Spring PetClinic app in detached mode:

```
docker compose up -d
```

✅ Verification
|Action |	Command	| Expected Result|
|------|----------|----------------|
|**Check containers**	| docker ps	| Both petclinic_db_container and spring_petclinic_app are running (Up)|
|**Check application logs** |	docker logs spring_petclinic_app |	Shows: Started PetClinicApplication...|
|**Access application	Open** | http://localhost:8080 |	PetClinic landing page loads & connects to PostgreSQL|






4️⃣ Jenkins Pipeline for CI/CD

This project includes a Jenkins declarative pipeline that automates the building, packaging, and deployment of the Spring PetClinic application with Docker.

**Pipeline Overview**

  *The pipeline performs the following automated steps:*

    -Checkout SCM

    -Pulls the latest code from GitHub (main branch).

    -Uses Jenkins credentials (github-credentials) for authentication.

    -Run Docker Compose

    -Stops any running containers (docker-compose down) safely.

    -Builds and starts the PostgreSQL database and Spring PetClinic app (docker-compose up -d --build).

    -Build Docker Image

    -Creates a new Docker image for the application.

    -Tags the image with the build number: ahmedzain10/spring-petclinic-prod:V<BUILD_NUMBER>.

    -Push Docker Image to Docker Hub

    -Authenticates to Docker Hub using the docker-hub-token credentials.

    -Pushes the newly built image to Docker Hub for deployment or sharing.



**Jenkinsfile**
```
pipeline {
    agent any

    environment {
        IMAGE_NAME = 'ahmedzain10/spring-petclinic-prod'
        IMAGE_TAG  = "V${env.BUILD_NUMBER}"
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

```
**Key Features**

  -Automated CI/CD: No manual steps required after initial Jenkins setup.

  -Dynamic Docker Tags: Each build gets a unique version tag (V<BUILD_NUMBER>).

  -Integrated with Docker Hub: Easy sharing and deployment of images.

  -Local Environment Support: Works with docker-compose for local testing.


**GitHub Webhook Integration**

To automate the pipeline trigger on every code push, a GitHub webhook has been configured to notify Jenkins.

*Steps Taken:*
```
# تحديث الحزم
sudo apt update

# تثبيت Node.js و npm
sudo apt install nodejs npm -y

# التأكد من النسخ
node -v
npm -v
```

Installed LocalTunnel to expose Jenkins running locally to the internet:
```
sudo npm install -g localtunnel
```

Started LocalTunnel to forward Jenkins port 8088:
```
lt --port 8088 --subdomain mypetclinic  
```
```
#port 8088 is the port which jenkins works in.
```

This provided a public URL like:
```
https://mypetclinic.loca.lt
```

*Configured the GitHub repository webhook:*
GitHub:

Settings → Webhooks → Add webhook

-Payload URL: https://mypetclinic.loca.lt/github-webhook/

-Content type: application/json

-Trigger: Just the push event

-Active: Enabled

-With this setup, any push to the main branch triggers the Jenkins pipeline automatically, building, pushing, and deploying 
 the Docker image.

---

## 5️⃣ Kubernetes Deployment (Production-Ready)

The application is deployed on Kubernetes with enterprise-grade features for high availability, auto-scaling, and zero-downtime updates.

### 🎯 Key Features

| Feature | Implementation | Benefit |
|---------|---------------|---------|
| **High Availability** | 2 pod replicas | Zero downtime, fault tolerance |
| **Auto-Scaling** | HPA (2-5 pods) | Automatic scaling based on CPU/Memory |
| **Resource Management** | CPU/Memory limits | Prevents resource exhaustion |
| **Health Monitoring** | Liveness/Readiness/Startup probes | Self-healing capabilities |
| **Rolling Updates** | Zero downtime strategy | Seamless deployments |
| **Persistent Storage** | 5Gi PVC for PostgreSQL | Data survives pod restarts |
| **Configuration** | ConfigMap | Centralized application settings |
| **Monitoring** | Prometheus annotations | Observability ready |

### 📦 Kubernetes Components

**Database (`k8s/db.yml`):**
- PostgreSQL 17.5 with persistent storage
- Resource limits: 256Mi-512Mi RAM, 250m-500m CPU
- Enhanced health probes for reliability
- Secure credential management via Secrets

**Application (`k8s/petclinic.yml`):**
- Spring Boot app with 2 replicas
- Resource limits: 512Mi-1Gi RAM, 500m-1000m CPU
- Actuator-based health endpoints
- Rolling update strategy (maxUnavailable: 0)
- NodePort service for external access

**Auto-Scaling (`k8s/hpa.yml`):**
- Scales from 2 to 5 replicas
- CPU threshold: 70%
- Memory threshold: 80%
- Smart scale-up/down policies

**Configuration (`k8s/configmap.yml`):**
- Application properties
- Logging configuration
- Actuator endpoint settings

### 🚀 Quick Deploy

```bash
# Deploy database
kubectl apply -f k8s/db.yml

# Deploy application
kubectl apply -f k8s/petclinic.yml

# Deploy auto-scaling (optional)
kubectl apply -f k8s/hpa.yml

# Access the application
minikube service petclinic
```

**Detailed instructions available in:** [`k8s/README.md`](k8s/README.md)

---

## 🎉 Project Completion Status

| Component | Status | Details |
|-----------|--------|---------|
| ✅ **Containerization** | Complete | Multi-stage Docker build |
| ✅ **Docker Compose** | Complete | Local development environment |
| ✅ **CI/CD Pipeline** | Complete | Jenkins with GitHub webhooks |
| ✅ **Docker Registry** | Complete | Images on Docker Hub |
| ✅ **Kubernetes** | Complete | Production-ready with HPA |
| ✅ **Infrastructure as Code** | Complete | Terraform for AWS deployment |
| 🔄 **Monitoring** | Planned | Prometheus & Grafana setup |

---

## 📚 Documentation

- **Main Project**: [`README.md`](README.md) (This file)
- **Kubernetes**: [`k8s/README.md`](k8s/README.md) - Detailed K8s deployment guide
- **Terraform**: [`terraform/Readme.md`](terraform/Readme.md) - AWS infrastructure setup

---


<!-- This Is A Test For The Pipeline -->
