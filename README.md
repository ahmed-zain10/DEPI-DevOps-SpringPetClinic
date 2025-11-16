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
| **Automation** | GitHub Actions | CI/CD pipeline for build, push, deploy |
| **Orchestration** | Kubernetes (K8s) | Scalable & highly available deployment |
| **Monitoring** | Prometheus & Grafana | Metrics collection & dashboard visualization |

---

##  Current State: Dockerization Complete

The application build and packaging pipeline is complete.  
The Docker image has been successfully built and pushed to **Docker Hub**.

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
✅ Verification
Action	Command	Expected Result
Check containers	docker ps	Both petclinic_db_container and spring_petclinic_app are running (Up)
Check application logs	docker logs spring_petclinic_app	Shows: Started PetClinicApplication...
Access application	Open: http://localhost:8080	PetClinic landing page loads & connects to PostgreSQL
