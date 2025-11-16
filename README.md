# Flask Kubernetes CI/CD Pipeline

A complete Continuous Integration and Continuous Delivery (CI/CD) pipeline for a Python Flask application with Kubernetes orchestration, automated testing, and deployment.

## Project Overview

This project demonstrates a professional DevOps workflow implementing:
- **Version Control**: Git and GitHub with branch protection
- **Continuous Integration**: GitHub Actions for automated testing and Docker builds
- **Continuous Delivery**: Jenkins pipeline for automated Kubernetes deployments
- **Container Orchestration**: Kubernetes with minikube for local deployment
- **Containerization**: Multi-stage Docker builds for optimized images

## Kubernetes Features Used

### 1. **Deployment with Rolling Updates**
- Configured `RollingUpdate` strategy for zero-downtime deployments
- `maxSurge`: Controls how many pods can be created above desired count during updates
- `maxUnavailable`: Controls how many pods can be unavailable during updates
- Ensures smooth transitions between application versions

### 2. **Horizontal Scaling**
- Multiple replica pods for high availability
- Easy scaling with `kubectl scale` command
- Load distribution across multiple instances

### 3. **Service Load Balancing**
- NodePort service type for external access
- Automatic load balancing across healthy pods
- Service discovery within the cluster

### 4. **Resource Management**
- Resource requests: Guaranteed minimum resources per pod
- Resource limits: Maximum resources a pod can consume
- Prevents resource starvation and ensures fair allocation

### 5. **Self-Healing**
- Automatic pod restart on failures
- Health checks for application availability
- Maintains desired state automatically

## Prerequisites

- Python 3.10+
- Docker
- Kubernetes (minikube)
- kubectl CLI
- Jenkins (for CD pipeline)
- Git

## Local Development

### Building and Running with Docker

1. **Clone the repository**
```bash
git clone https://github.com/AbdullahButt-00/Flask-k8s-CI-CD-Assignment.git
cd Flask-k8s-CI-CD-Assignment
```

2. **Build the Docker image**
```bash
docker build -t flask-k8s-app:latest .
```

3. **Run the container locally**
```bash
docker run -p 5000:5000 flask-k8s-app:latest
```

4. **Access the application**
```
http://localhost:5000
```

### Running Tests Locally

```bash
# Install dependencies
pip install -r requirements.txt

# Run linting
flake8 . --max-line-length=90

# Run unit tests
pytest
```

## Kubernetes Deployment

### Manual Deployment to Minikube

1. **Start minikube**
```bash
minikube start
```

2. **Build image in minikube's Docker environment**
```bash
eval $(minikube docker-env)
docker build -t flask-k8s-app:latest .
```

3. **Apply Kubernetes manifests**
```bash
kubectl apply -f kubernetes/deployment.yaml
kubectl apply -f kubernetes/service.yaml
```

4. **Verify deployment**
```bash
kubectl get deployments
kubectl get pods
kubectl get services
```

5. **Access the application**
```bash
minikube service flask-service
```

### Scaling the Application

```bash
# Scale to 5 replicas
kubectl scale deployment flask-app --replicas=5

# Verify scaling
kubectl get pods
```

### Rolling Updates

```bash
# Update the image
kubectl set image deployment/flask-app flask-app=flask-k8s-app:v2

# Monitor rollout
kubectl rollout status deployment/flask-app

# View rollout history
kubectl rollout history deployment/flask-app
```

### Rollback Deployment

```bash
# Rollback to previous version
kubectl rollout undo deployment/flask-app

# Rollback to specific revision
kubectl rollout undo deployment/flask-app --to-revision=2
```

## Jenkins Pipeline Deployment

### Pipeline Overview

The Jenkins pipeline automates the entire deployment process with three stages:

1. **Build Docker Image**: Creates optimized Docker image using multi-stage build
2. **Kubernetes Deployment**: Applies deployment and service manifests
3. **Deployment Verification**: Validates successful rollout and pod health

### Setting Up Jenkins Pipeline

1. **Install Jenkins and required plugins**
   - Docker Pipeline
   - Kubernetes CLI
   - Git plugin

2. **Configure kubectl in Jenkins**
```bash
# Copy kubeconfig to Jenkins
mkdir -p /var/lib/jenkins/.kube
cp ~/.kube/config /var/lib/jenkins/.kube/config
chown -R jenkins:jenkins /var/lib/jenkins/.kube
```

3. **Create Pipeline Job**
   - New Item → Pipeline
   - Configure SCM: Git
   - Repository URL: `https://github.com/AbdullahButt-00/Flask-k8s-CI-CD-Assignment.git`
   - Branch: `*/main`
   - Script Path: `Jenkinsfile`

4. **Run the Pipeline**
   - Click "Build Now"
   - Monitor console output for deployment status
   - Verify pods are running in Kubernetes

### Pipeline Stages Explained

**Stage 1: Build Docker Image**
- Builds the Flask application Docker image
- Uses multi-stage build for smaller image size
- Tags image as `flask-k8s-app:latest`

**Stage 2: Kubernetes Deployment**
- Applies deployment configuration
- Applies service configuration
- Creates/updates Kubernetes resources

**Stage 3: Deployment Verification**
- Checks rollout status
- Displays running pods
- Displays service information
- Ensures deployment succeeded

## Automated Rollouts, Scaling, and Load Balancing

### Rolling Updates Strategy

The deployment uses a `RollingUpdate` strategy configured in `deployment.yaml`:

```yaml
strategy:
  type: RollingUpdate
  rollingUpdate:
    maxSurge: 1        # Max 1 extra pod during updates
    maxUnavailable: 0  # All pods must be available
```

**Benefits:**
- Zero downtime during updates
- Gradual rollout minimizes risk
- Automatic rollback if health checks fail

### Horizontal Scaling

Kubernetes automatically distributes traffic across multiple replicas:

- **Initial replicas**: Configured in deployment.yaml
- **Manual scaling**: `kubectl scale deployment flask-app --replicas=N`
- **Auto-scaling**: Can be configured with HPA (Horizontal Pod Autoscaler)

**Scaling Benefits:**
- High availability
- Better resource utilization
- Handles increased traffic load

### Load Balancing

The NodePort service automatically load balances:

```yaml
type: NodePort
ports:
  - port: 5000
    targetPort: 5000
    nodePort: 30080
```

**Load Balancing Features:**
- Distributes requests across healthy pods
- Session affinity options available
- Health-based routing (unhealthy pods excluded)
- Works seamlessly with rolling updates

## CI/CD Workflow

1. **Developer pushes code** → `feature/*` branch
2. **GitHub Actions triggers** → Runs tests, linting, Docker build
3. **Pull Request created** → Admin reviews changes
4. **Merge to develop** → Integration testing
5. **Merge to main** → Jenkins pipeline deploys to Kubernetes
6. **Kubernetes applies** → Rolling update with zero downtime
7. **Verification** → Health checks ensure successful deployment

## Project Structure

```
.
├── app.py                      # Flask application
├── requirements.txt            # Python dependencies
├── Dockerfile                  # Multi-stage Docker build
├── Jenkinsfile                 # Jenkins pipeline definition
├── kubernetes/
│   ├── deployment.yaml         # Kubernetes Deployment manifest
│   └── service.yaml            # Kubernetes Service manifest
├── .github/
│   └── workflows/
│       └── ci.yml             # GitHub Actions CI workflow
├── tests/                      # Unit tests
└── README.md                   # This file
```

## Monitoring and Troubleshooting

### Check Pod Status
```bash
kubectl get pods -o wide
kubectl describe pod <pod-name>
kubectl logs <pod-name>
```

### Check Deployment Status
```bash
kubectl get deployments
kubectl describe deployment flask-app
kubectl rollout status deployment/flask-app
```

### Check Service
```bash
kubectl get services
kubectl describe service flask-service
```

### Common Issues

**Pods not starting:**
- Check image pull policy
- Verify resource limits
- Review pod logs: `kubectl logs <pod-name>`

**Service not accessible:**
- Verify NodePort is open
- Check minikube service: `minikube service flask-service`
- Ensure pods are in Running state

**Rolling update stuck:**
- Check readiness probes
- Verify new image exists
- Review rollout history: `kubectl rollout history deployment/flask-app`

## Contributors

- **Abdullah Butt** - Developer (Repository: AbdullahButt-00)
- **Immad Shah** - Admin

## License

This project is created for educational purposes as part of the Cloud MLOps course assignment.

## Acknowledgments

- Course: Cloud MLOps (BS AI)
- Assignment: End-to-End CI/CD Pipeline
- Tools: Git, GitHub Actions, Jenkins, Docker, Kubernetes (minikube)
