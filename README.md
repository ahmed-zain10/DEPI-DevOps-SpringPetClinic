#  DEPI DevOps Track — Automated DevOps Pipeline for Spring PetClinic

A complete end-to-end DevOps implementation for the **Spring PetClinic** application as part of the **Digital Egypt Pioneers Initiative (DEPI)** DevOps Track.  
The project covers containerization, local environment setup, automation, cloud infrastructure, orchestration, and monitoring.

---

# Overview

**Spring PetClinic** is a well-structured Java/Spring Boot application that makes it ideal for building and demonstrating real DevOps pipelines.  
It includes:
- **UI Layer** – User-facing features  
- **Service Layer** – Business logic  
- **Persistence Layer** – PostgreSQL database integration  

This project applies modern DevOps practices to automate the lifecycle of the application.

---

## 🗺️ DevOps Roadmap

| Phase                    | Tool                        | Goal |
|--------------------------|------------------------------|------|
| **Containerization**     | Docker                       | Build optimized multi-stage container images |
| **Local Environment**    | Docker Compose               | Run the full stack locally (App + DB) |
| **IaC**                  | Terraform + AWS              | Provision cloud infrastructure |
| **Config Management**    | Ansible                      | Automate VM / host configuration |
| **CI/CD**                | GitHub Actions               | Build, test, push, deploy automatically |
| **Orchestration**        | Kubernetes                   | Scalable & resilient application deployment |
| **Monitoring**           | Prometheus + Grafana         | Metrics, dashboards, and real-time insights |

---

##  Current Progress — Dockerization Complete

### ✔ Multi-Stage Dockerfile

```dockerfile
# --- STAGE 1: Build ---
FROM maven:3.8.5-openjdk-17 AS builder
WORKDIR /app
COPY pom.xml .
RUN mvn dependency:go-offline
COPY src ./src
RUN mvn clean package -DskipTests

# --- STAGE 2: Run ---
FROM eclipse-temurin:17-jre-alpine
WORKDIR /app
COPY --from=builder /app/target/*.jar app.jar
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]



Docker Compose Setup
This configuration spins up PostgreSQL + Spring PetClinic using the final production image from Docker Hub.

yaml
Copy code
services:
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




▶️ Running the Stack
Start everything in detached mode:

bash
Copy code
docker compose up -d
🔍 Verification Checklist
Check	Command	Expected Output
Running containers	docker ps	Both containers show “Up”
Application logs	docker logs spring_petclinic_app	Message: Started PetClinicApplication…
App is live	Visit http://localhost:8080	PetClinic UI loads and connects to PostgreSQL

