# 🚀 Deploying a Node.js Web Application on AWS Free Tier Using Docker & Kubernetes

**Course:** Cloud Computing (BS CS)  
**Submission Type:** Individual  
**Due Date:** June 1, 2026

---

## 📋 Table of Contents

1. [Project Overview](#project-overview)
2. [Prerequisites](#prerequisites)
3. [Project Structure](#project-structure)
4. [Quick Start Guide](#quick-start-guide)
5. [Phase-by-Phase Implementation](#phase-by-phase-implementation)
6. [Deliverables Checklist](#deliverables-checklist)
7. [Cleanup](#cleanup)
8. [Troubleshooting](#troubleshooting)

---

## Project Overview

This project demonstrates the end-to-end deployment of a containerized Node.js web application on AWS entirely within the **Free Tier** limits. The application displays dynamic content (timestamp, container ID, and visitor counter) and is publicly accessible via an EC2 instance's public IP address.

### Architecture

```
┌─────────────────┐     ┌──────────────────┐     ┌─────────────────┐
│   Developer     │────▶│  Amazon ECR      │────▶│   EC2 t2.micro  │
│   Machine       │     │  (Container      │     │   (Minikube +   │
│                 │     │   Registry)      │     │    Docker)      │
└─────────────────┘     └──────────────────┘     └─────────────────┘
                                                          │
                                                          ▼
                                                   ┌──────────────┐
                                                   │  App Host    │
                                                   │  :3000       │
                                                   └──────────────┘
                                                          │
                                                          ▼
                                                   ┌──────────────┐
                                                   │   Internet   │
                                                   │   Users      │
                                                   └──────────────┘
```

**Primary Goal:** Understand containerization, container registry usage, and Kubernetes deployment on a single-node cluster.

---

## Prerequisites

Install these tools on your local machine before starting:

| Tool | Version | Download Link |
|------|---------|---------------|
| Node.js | >= 18 | [nodejs.org](https://nodejs.org) |
| Docker Desktop | Latest | [docker.com](https://docker.com/products/docker-desktop) |
| AWS CLI | v2 | [aws.amazon.com/cli](https://aws.amazon.com/cli) |
| Git | Latest | [git-scm.com](https://git-scm.com) |
| AWS Account | Free Tier | [aws.amazon.com/free](https://aws.amazon.com/free) |

---

## Project Structure

```
Project-Sabeeh/
├── src/                          # Node.js application source
│   ├── app.js                    # Main Express server
│   └── package.json              # Node dependencies
├── Dockerfile                    # Multi-stage Docker build
├── k8s/                          # Kubernetes manifests
│   ├── deployment.yaml           # Pod deployment spec
│   └── service.yaml              # NodePort service spec
├── scripts/                      # Automation scripts
│   ├── setup-ec2.sh              # EC2 Minikube & Docker setup
│   ├── build-and-push.sh         # Build & push to ECR
│   └── deploy-k8s.sh             # Deploy to Minikube
├── docs/
│   ├── REPORT.pdf                # Final project report (8 pages)
│   ├── VIDEO_SCRIPT.md           # Demo video script
│   └── screenshot-guide.md       # Required screenshots guide
├── screenshots/                  # Screenshots for report
└── README.md                     # This file
```

---

## Quick Start Guide

### Step 1: Clone and Configure

```bash
git clone https://github.com/SabeehP09/Project-Sabeeh.git
cd Project-Sabeeh
```

Update the placeholders in the scripts:
- Replace `YOUR_AWS_ACCOUNT_ID` with your actual AWS Account ID.
- Replace `YOUR_REGION` with your AWS region (e.g., `us-east-1`).

### Run Locally via IP Address

You can run this app locally and access it from another device on the same network using the host machine's IP address.

#### Option A: Run with Node.js

```bash
cd src
npm install
npm start
```

Then open in your browser:

```text
http://<HOST_IP>:3000
```

#### Option B: Run with Docker

```bash
docker build -t nodejs-aws-k8s-app .
docker run -d --name nodejs-aws-k8s-app -p 3000:3000 nodejs-aws-k8s-app
```

Then open:

```text
http://<HOST_IP>:3000
```

> Make sure your machine firewall allows inbound traffic on port `3000`.

#### Option C: Run with Docker Compose

```bash
docker compose up --build
```

Then open:

```text
http://<HOST_IP>:3000
```

### Step 2: Build & Push to ECR

```bash
cd scripts
./build-and-push.sh us-east-1 123456789012 nodejs-aws-k8s-app latest
```

### Step 3: Launch EC2 Instance

1. Go to AWS Console → EC2 → Launch Instance
2. **Name:** `minikube-k8s-node`
3. **AMI:** Amazon Linux 2023 or Ubuntu Server 22.04 LTS
4. **Instance Type:** `t2.micro` (Free Tier eligible)
5. **Key Pair:** Create or select an existing key pair
6. **Security Group:** Allow SSH (22), HTTP (80), and Custom TCP (3000) from anywhere
7. **Storage:** 20 GB gp2 (Free Tier eligible)
8. Launch and note the **Public IPv4 address**

### Step 4: Setup EC2 (Minikube + Docker)

```bash
ssh -i your-key.pem ec2-user@<EC2_PUBLIC_IP>
# or ubuntu@<EC2_PUBLIC_IP> for Ubuntu

git clone https://github.com/SabeehP09/Project-Sabeeh.git
cd Project-Sabeeh/scripts
./setup-ec2.sh
```

> ⚠️ Log out and SSH back in for Docker group permissions to take effect.

### Step 5: Deploy to Kubernetes

```bash
cd Project-Sabeeh/scripts
./deploy-k8s.sh us-east-1 123456789012 nodejs-aws-k8s-app latest
```

### Step 6: Access the Application

Open your browser and navigate to:

```
http://<EC2_PUBLIC_IP>:3000
```


You should see the running Node.js application with:
- ⏰ Live timestamp
- 🐳 Container ID
- 👥 Visitor counter

---

## Phase-by-Phase Implementation

### Phase 1: Node.js Web Application

A lightweight Express server (`src/app.js`) serves an HTML page with:
- Real-time ISO timestamp
- Container hostname (shortened to 12 characters)
- Persistent visitor counter (stored in `counter.json`)
- `/health` endpoint for Kubernetes probes

### Phase 2: Docker Containerization

The `Dockerfile` uses a **multi-stage build**:
1. **Builder stage:** Installs production dependencies
2. **Production stage:** Copies only necessary files, runs as non-root user (`nodejs`), includes a `HEALTHCHECK`

Build locally:
```bash
docker build -t nodejs-aws-k8s-app:latest .
docker run -p 3000:3000 nodejs-aws-k8s-app:latest
```

### Phase 3: Push to Amazon ECR

The `build-and-push.sh` script:
1. Authenticates Docker with ECR
2. Creates the repository if missing
3. Builds and tags the image
4. Pushes to ECR

### Phase 4-5: EC2 & Minikube Setup

The `setup-ec2.sh` script installs:
- Docker CE
- kubectl
- Minikube (with Docker driver)
- AWS CLI v2

Then starts a single-node Minikube cluster.

### Phase 6: Authenticate EC2 to ECR

ECR login is performed in `deploy-k8s.sh` using:
```bash
aws ecr get-login-password ... | docker login ...
```

### Phase 7: Kubernetes Deployment

- **Deployment:** Runs the container with resource limits (64Mi-256Mi memory, 100m-250m CPU), liveness and readiness probes.
- **Service:** Exposes the app on port `3000`.

### Phase 8: Testing & Verification

```bash
# Verify pods
kubectl get pods

# Verify services
kubectl get services

# Check logs
kubectl logs -l app=nodejs-app

# Scale up (for demo)
kubectl scale deployment nodejs-app-deployment --replicas=2
```

### Phase 9: Clean Up Resources

```bash
# Delete Kubernetes resources
kubectl delete -f k8s/

# Stop Minikube
minikube stop
minikube delete

# Terminate EC2 instance from AWS Console
# Delete ECR repository from AWS Console
```

---

## Deliverables Checklist

| # | Deliverable | Status | Location |
|---|-------------|--------|----------|
| 1 | Public Application URL | ⬜ | `http://<EC2_IP>:3000` |
| 2 | Source Code Repository | ✅ | This GitHub repo |
| 3 | Project Report (8 pages) | ✅ | `docs/REPORT.pdf` |
| 4 | Demonstration Video (5 min) | ⬜ | YouTube Unlisted / Google Drive |
| 5 | Screenshots | ⬜ | `screenshots/` folder |

---

## Cleanup

To avoid any charges beyond Free Tier:
1. Delete the ECR repository and images.
2. Terminate the EC2 instance.
3. Delete any associated Elastic IPs (if allocated).
4. Verify in AWS Cost Explorer that charges are $0.00.

---

## Troubleshooting

| Issue | Solution |
|-------|----------|
| `permission denied` for Docker | Run `sudo usermod -aG docker $USER` and re-login |
| Minikube won't start | Ensure Docker is running: `sudo systemctl start docker` |
| ImagePullBackOff | Verify ECR login and image URI in deployment.yaml |
| Cannot access app on port 3000 | Open port 3000 in EC2 Security Group |
| Counter resets | Expected behavior on pod restart; uses file persistence within pod |

---

**Good Luck! 🎓**
