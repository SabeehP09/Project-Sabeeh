# Screenshot Guide for Project Report

This document lists the **minimum 6 required screenshots** with exact captions to embed in your final report.

---

## Required Screenshots

### 1. Running Application (Browser)
**File name:** `01-running-app.png`
**How to capture:**
- Open browser to `http://<EC2_PUBLIC_IP>:3000`
- Ensure the page shows:
  - Timestamp
  - Container ID
  - Visitor Counter (> 0)

**Caption:**
> *Figure 1: Node.js web application running in the browser, displaying live timestamp, container ID, and visitor counter via EC2 public IP on port 3000.*

---

### 2. Amazon ECR Repository
**File name:** `02-ecr-repository.png`
**How to capture:**
- AWS Console → ECR → Repositories
- Click on `nodejs-aws-k8s-app` repository
- Show the pushed image with tag `latest`

**Caption:**
> *Figure 2: Amazon Elastic Container Registry (ECR) showing the `nodejs-aws-k8s-app` repository with the `latest` image tag pushed from local Docker environment.*

---

### 3. EC2 Instance Dashboard
**File name:** `03-ec2-instance.png`
**How to capture:**
- AWS Console → EC2 → Instances
- Show the running `t2.micro` instance
- Highlight: Instance ID, Instance state (Running), Instance type, Public IPv4 address

**Caption:**
> *Figure 3: AWS EC2 Management Console displaying the running `t2.micro` instance (Free Tier eligible) with its public IPv4 address and running state.*

---

### 4. Minikube Cluster Status
**File name:** `04-minikube-status.png`
**How to capture:**
- SSH into EC2 instance
- Run: `minikube status`
- Also run: `kubectl get nodes`
- Show both outputs in one terminal window

**Caption:**
> *Figure 4: Minikube cluster status and Kubernetes node verification on the EC2 instance, confirming the single-node cluster is active and ready.*

---

### 5. Deployed Pods
**File name:** `05-deployed-pods.png`
**How to capture:**
- On EC2 terminal, run: `kubectl get pods -o wide`
- Show pod name, status (`Running`), restarts, age, and node
- Optional: show scaling to 2 replicas for extra impact

**Caption:**
> *Figure 5: Kubernetes pods in `Running` state, deployed via the ECR image on the Minikube cluster, showing successful container orchestration.*

---

### 6. Kubernetes Services
**File name:** `06-k8s-services.png`
**How to capture:**
- On EC2 terminal, run: `kubectl get services`
- Show `nodejs-app-service` with type `ClusterIP` and port `80/TCP`

**Caption:**
> *Figure 6: Kubernetes Service exposing the Node.js application internally on port 80, with the frontend available through the EC2 host on port 3000.*

---

## Bonus Screenshots (Optional but Recommended)

| # | Screenshot | Command / Location |
|---|------------|-------------------|
| 7 | Docker image build log | Terminal: `docker build -t nodejs-aws-k8s-app .` |
| 8 | Health endpoint JSON | Browser: `http://<EC2_IP>:3000/health` |
| 9 | Scaling demonstration | Terminal: `kubectl scale --replicas=2 deployment/nodejs-app-deployment` |
| 10 | AWS Cost Explorer ($0) | AWS Console → Billing → Cost Explorer → MTD |

---

## Screenshot Formatting Tips

- Use **PNG** format for clarity.
- Crop unnecessary browser tabs and bookmarks.
- Highlight important values using **red boxes or arrows** (Snipping Tool, Preview, or GIMP).
- Ensure text is readable when printed in the PDF report.

---

**Place all final screenshots in the `/screenshots/` folder before embedding them into the report.**
