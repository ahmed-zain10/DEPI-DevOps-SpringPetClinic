🚀 DEPI DevOps Track:  Automation for Spring PetClinic

🌟 Project Overview

This repository showcases a comprehensive, full-stack DevOps pipeline for the Spring PetClinic application, a standard web application used for managing veterinary clinic operations.

This project is a mandatory deliverable for the Digital Egypt Pioneers Initiative (DEPI) DevOps Track.

Application Significance

The Spring PetClinic application serves as an ideal DevOps candidate as it encompasses all critical components:

User Interface (UI): For user interaction.

Service Layer: For business logic.

Persistence Layer: Connecting to an external PostgreSQL database.

🗺️ Planned DevOps Roadmap

This project aims to implement Continuous Integration, Delivery, and Monitoring (CI/CD/CM) using modern industry tools:

Phase

Core Tool

Objective

Containerization

Docker

Build optimized, multi-stage Docker images for the application.

Local Environment

Docker Compose

Define and run the complete application environment (App + DB) locally.

Infrastructure as Code (IaC)

Terraform & AWS

Define and provision the necessary cloud infrastructure on AWS.

Configuration Mgmt.

Ansible

Automate the configuration and setup of deployment hosts (e.g., Ubuntu VMs).

Automation

GitHub Actions

Implement a CI/CD pipeline for automated build, push, and deployment.

Orchestration

Kubernetes (K8s)

Deploy the application in a scalable, highly available cluster environment.

Monitoring

Prometheus & Grafana

Collect application and infrastructure metrics, and visualize performance using Dashboards.

🏗️ Current State: Dockerization Complete

The application build and packaging process is complete. The application image has been successfully built and pushed to Docker Hub.

1. The Dockerfile

We are using an optimized multi-stage build approach to minimize the final image size by leveraging the lightweight eclipse-temurin:17-jre-alpine image for runtime.

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



2. Docker Compose Configuration

The following docker-compose.yml file defines the PostgreSQL database and pulls the latest version of the application image from Docker Hub.

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
    # Image successfully built and pushed to Docker Hub
    image: ahmedzain10/spring-petclinic-prod:latest 
    container_name: spring_petclinic_app
    restart: always
    ports:
      - "8080:8080"
    environment:
      # Database connection details (using 'db' as hostname inside the Docker network)
      SPRING_DATASOURCE_URL: jdbc:postgresql://db:5432/petclinic_db
      SPRING_DATASOURCE_USERNAME: petuser
      SPRING_DATASOURCE_PASSWORD: petpassword_secure
      # Activate PostgreSQL profile to load necessary schema/data scripts
      SPRING_PROFILES_ACTIVE: postgres 
    depends_on:
      - db

volumes:
  postgres_data:



3. Running the Environment

Use the following command to start both the PostgreSQL database and the Spring PetClinic application in detached mode (-d):

docker compose up -d



Verification

Action

Command

Expected Result

Check containers

docker ps

Both petclinic_db_container and spring_petclinic_app are running (Up).

Check application logs

docker logs spring_petclinic_app

Look for the final message: Started PetClinicApplication...

Access Application

Navigate to http://localhost:8080

The PetClinic landing page should load successfully, connected to PostgreSQL.
