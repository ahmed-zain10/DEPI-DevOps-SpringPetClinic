# Kubernetes Deployment for Spring PetClinic

This directory contains Kubernetes manifests to deploy the Spring PetClinic application with PostgreSQL database on a Kubernetes cluster.

## 📁 Files Overview

### `db.yml`
Deploys PostgreSQL database with:
- **Secret**: Database credentials (`petuser`, `petpassword_secure`, `petclinic_db`)
- **Service**: ClusterIP service exposing port 5432
- **Deployment**: PostgreSQL 17.5 container with:
  - Resource limits (256Mi-512Mi RAM, 250m-500m CPU)
  - Enhanced health probes (liveness, readiness, startup)
  - Recreate deployment strategy for data integrity
- **PersistentVolumeClaim**: 5Gi persistent storage for database data

### `petclinic.yml`
Deploys the Spring PetClinic application with:
- **Service**: NodePort service exposing the application (port 80 → 8080)
- **Deployment**: Spring Boot application with:
  - Image: `ahmedzain10/spring-petclinic-prod:V1.0`
  - 2 replicas for high availability
  - Resource limits (512Mi-1Gi RAM, 500m-1000m CPU)
  - Rolling update strategy (zero downtime)
  - Actuator health endpoints
  - Prometheus metrics annotations

### `configmap.yml`
Application configuration:
- Spring Boot properties
- Logging levels
- Actuator endpoints configuration

### `hpa.yml` (Optional)
HorizontalPodAutoscaler for auto-scaling:
- Scales from 2 to 5 replicas
- Based on CPU (70%) and Memory (80%) usage
- Smart scale-up/down policies

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

### Step 3: Deploy Configuration (Optional)
```bash
kubectl apply -f k8s/configmap.yml
```

### Step 4: Deploy the Application
```bash
kubectl apply -f k8s/petclinic.yml
```

### Step 5: Deploy Auto-Scaling (Optional)
```bash
# Requires metrics-server to be installed
kubectl apply -f k8s/hpa.yml
```

### Step 6: Verify Application is Running
```bash
kubectl get pods -l app=petclinic
kubectl get svc petclinic
kubectl get hpa petclinic-hpa  # If HPA was deployed
```

Wait until pod status shows `2/2 READY` (2 replicas running).

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

### Scale the Application (Manual)
```bash
# Manual scaling (if HPA not enabled)
kubectl scale deployment petclinic --replicas=3
```

### Monitor Auto-Scaling
```bash
# Watch HPA in action
kubectl get hpa petclinic-hpa --watch

# Check resource usage
kubectl top pods
kubectl top nodes
```

### Check Actuator Endpoints
```bash
# Forward port
kubectl port-forward svc/petclinic 8080:80

# Health endpoints
curl http://localhost:8080/actuator/health
curl http://localhost:8080/actuator/health/liveness
curl http://localhost:8080/actuator/health/readiness
curl http://localhost:8080/actuator/metrics
```

### Delete All Resources
```bash
kubectl delete -f k8s/hpa.yml
kubectl delete -f k8s/petclinic.yml
kubectl delete -f k8s/configmap.yml
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

## 🎯 Production Features Summary

| Feature | Configuration | Benefit |
|---------|--------------|---------|
| **High Availability** | 2 replicas | Zero downtime |
| **Auto-Scaling** | HPA (2-5 pods) | Handles traffic spikes |
| **Resource Management** | CPU/Memory limits | Prevents resource exhaustion |
| **Health Monitoring** | Liveness/Readiness/Startup probes | Self-healing pods |
| **Rolling Updates** | maxUnavailable: 0 | Zero downtime deployments |
| **Persistent Storage** | 5Gi PVC | Data survives restarts |
| **Metrics** | Prometheus annotations | Observability ready |
| **Configuration** | ConfigMap | Centralized settings |

## 📈 Expected Deployment Status

After successful deployment, you should see:

```bash
# kubectl get all
NAME                             READY   STATUS    RESTARTS   AGE
pod/demo-db-77d44f9d6-xxxxx      1/1     Running   0          10m
pod/petclinic-695596f65b-xxxxx   1/1     Running   0          9m
pod/petclinic-695596f65b-yyyyy   1/1     Running   0          8m

NAME                TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)        AGE
service/demo-db     ClusterIP   10.110.23.33     <none>        5432/TCP       10m
service/petclinic   NodePort    10.108.172.195   <none>        80:32395/TCP   10m

NAME                        READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/demo-db     1/1     1            1           10m
deployment.apps/petclinic   2/2     2            2           10m

NAME                                                REFERENCE              TARGETS                      MINPODS   MAXPODS   REPLICAS   AGE
horizontalpodautoscaler.autoscaling/petclinic-hpa   Deployment/petclinic   cpu: 1%/70%, memory: 41%/80%   2         5         2          5m
```

---

**Access the application in your browser using any of the methods above and enjoy managing your pet clinic!** 🐾
