# Kubernetes Deployment for Spring PetClinic

This directory contains Kubernetes manifests to deploy the Spring PetClinic application with PostgreSQL database on a Kubernetes cluster.

## 📁 Files Overview

### `db.yml`
Deploys PostgreSQL database with:
- **Secret**: Database credentials (`petuser`, `petpassword_secure`, `petclinic_db`)
- **Service**: ClusterIP service exposing port 5432
- **Deployment**: PostgreSQL 17.5 container
- **PersistentVolumeClaim**: 5Gi persistent storage for database data

### `petclinic.yml`
Deploys the Spring PetClinic application with:
- **Service**: NodePort service exposing the application (port 80 → 8080)
- **Deployment**: Spring Boot application container
  - Image: `ahmedzain10/spring-petclinic-prod:V1.0`
  - Profile: `postgres`
  - Health probes: Liveness and Readiness checks

## 🚀 Deployment Instructions

### Prerequisites
- Kubernetes cluster running (Minikube, Kind, or any K8s cluster)
- `kubectl` configured to connect to your cluster

### Step 1: Deploy the Database
```bash
kubectl apply -f k8s/db.yml
```

This creates:
- PostgreSQL database
- Persistent storage (5Gi)
- Database credentials secret
- Internal service for database access

### Step 2: Verify Database is Running
```bash
kubectl wait --for=condition=ready pod -l app=demo-db --timeout=60s
kubectl get pods -l app=demo-db
```

### Step 3: Deploy the Application
```bash
kubectl apply -f k8s/petclinic.yml
```

### Step 4: Verify Application is Running
```bash
kubectl get pods -l app=petclinic
kubectl get svc petclinic
```

Wait until the pod status shows `1/1 READY`.

## 🌐 Accessing the Application

### Option 1: Using Minikube Service (Recommended for Minikube)
```bash
minikube service petclinic
```

This will automatically open the application in your default browser.

To get the URL without opening the browser:
```bash
minikube service petclinic --url
```

### Option 2: Using kubectl Port-Forward
```bash
kubectl port-forward svc/petclinic 8080:80
```

Then access the application at: **http://localhost:8080**

### Option 3: Using NodePort (Direct Access)
Get the Minikube IP and NodePort:
```bash
minikube ip
kubectl get svc petclinic
```

Access the application at: `http://<MINIKUBE_IP>:<NODE_PORT>`

Example: `http://192.168.49.2:32395`

### Option 4: Using LoadBalancer with Minikube Tunnel
If you changed the service type to LoadBalancer, run:
```bash
minikube tunnel
```

Keep this terminal open, then access via: `http://localhost`

## 🔍 Useful Commands

### Check All Resources
```bash
kubectl get all
```

### View Application Logs
```bash
kubectl logs -l app=petclinic
kubectl logs -l app=petclinic -f  # Follow logs
```

### View Database Logs
```bash
kubectl logs -l app=demo-db
```

### Check Pod Details
```bash
kubectl describe pod -l app=petclinic
kubectl describe pod -l app=demo-db
```

### Scale the Application
```bash
kubectl scale deployment petclinic --replicas=3
```

### Delete All Resources
```bash
kubectl delete -f k8s/petclinic.yml
kubectl delete -f k8s/db.yml
```

## 🔧 Configuration Details

### Database Connection
The application connects to PostgreSQL using:
- **Host**: `demo-db` (Kubernetes service name)
- **Port**: `5432`
- **Database**: `petclinic_db`
- **Username**: `petuser` (from Secret)
- **Password**: `petpassword_secure` (from Secret)

### Environment Variables
The application container uses:
- `SPRING_PROFILES_ACTIVE=postgres` - Activates PostgreSQL profile
- `SPRING_DATASOURCE_URL` - PostgreSQL connection string
- `SPRING_DATASOURCE_USERNAME` - Database username (from Secret)
- `SPRING_DATASOURCE_PASSWORD` - Database password (from Secret)

### Health Checks
- **Liveness Probe**: HTTP GET `/` (checks if app is alive)
- **Readiness Probe**: HTTP GET `/` (checks if app is ready to serve traffic)
- Initial delays: 60s (liveness), 30s (readiness)

## 🛠️ Troubleshooting

### Pod Not Starting
```bash
kubectl describe pod -l app=petclinic
kubectl logs -l app=petclinic
```

### Database Connection Issues
Check if database is running:
```bash
kubectl get pods -l app=demo-db
kubectl logs -l app=demo-db
```

### Image Pull Errors
Verify the image exists on Docker Hub:
```bash
docker pull ahmedzain10/spring-petclinic-prod:V1.0
```

### Persistent Volume Issues
Check PVC status:
```bash
kubectl get pvc
kubectl describe pvc postgres-pvc
```

## 📊 Application Features

Once deployed, you can:
- ✅ View and manage pet owners
- ✅ Add and manage pets
- ✅ Schedule veterinary visits
- ✅ View veterinarians and their specialties
- ✅ Data persists across pod restarts (PostgreSQL with PVC)

---

**Access the application in your browser using any of the methods above and enjoy managing your pet clinic!** 🐾
