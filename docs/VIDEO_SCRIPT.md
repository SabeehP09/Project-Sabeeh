# Demonstration Video Script (5 Minutes Max)

## Overview
Follow this script exactly to produce a concise, professional 5-minute demonstration video.

---

## Scene Breakdown

### 00:00 – 00:30 | Introduction
**On Camera / Voiceover:**
> "Hello, my name is [Your Name], and this is my Cloud Computing project: Deploying a Node.js Web Application on AWS Free Tier Using Docker and Kubernetes. The goal of this project is to demonstrate the complete end-to-end workflow of containerization, storing images in Amazon ECR, and deploying to a Kubernetes cluster running on a single EC2 t2.micro instance using Minikube — all within AWS Free Tier limits, meaning zero cost."

**Visuals:**
- Show yourself (optional) or display a title slide.
- Show the AWS Free Tier pricing page briefly.

---

### 00:30 – 01:30 | GitHub Repository Walkthrough
**Voiceover:**
> "First, let's look at the source code repository hosted on GitHub. The repository contains three main components: the Node.js application, the Dockerfile for containerization, and the Kubernetes YAML manifests for deployment."

**Visuals (Screen Recording):**
1. Open GitHub repository in browser: https://github.com/SabeehP09/Project-Sabeeh
2. Highlight `src/app.js` — scroll to show timestamp, container ID, and visitor counter logic.
3. Highlight `Dockerfile` — mention multi-stage build and security best practices.
4. Highlight `k8s/deployment.yaml` and `k8s/service.yaml` — explain replicas, resource limits, and NodePort.
5. Highlight `scripts/` folder — mention automation.

---

### 01:30 – 02:00 | Amazon ECR (AWS Console)
**Voiceover:**
> "The Docker image has been built and pushed to Amazon Elastic Container Registry. ECR offers 500 MB of free storage per month, which is more than enough for our lightweight Node.js image."

**Visuals (Screen Recording):**
1. Open AWS Console → ECR.
2. Show the repository name: `nodejs-aws-k8s-app`.
3. Click into the repository and show the image tag (`latest`).
4. Show the image size (should be < 200 MB).
5. Copy the image URI and show it on screen.

---

### 02:00 – 02:30 | EC2 Instance & SSH Connection
**Voiceover:**
> "Next, I have launched an EC2 t2.micro instance, which is free tier eligible for 750 hours per month. I have installed Docker, Minikube, and kubectl on this instance. Let's verify it's running and connect via SSH."

**Visuals (Screen Recording):**
1. AWS Console → EC2 → Instances.
2. Show instance state: **Running**.
3. Show instance type: **t2.micro**.
4. Show public IPv4 address.
5. Open terminal → run SSH command.
6. On EC2, run: `docker --version`, `kubectl version --client`, `minikube version`.

---

### 02:30 – 03:30 | LIVE DEMO — Kubernetes Deployment
**Voiceover:**
> "Now for the live deployment demo. I will apply the Kubernetes manifests and verify that the pods and services are running correctly."

**Visuals (Screen Recording):**
1. Terminal on EC2:
   ```bash
   cd Project-Sabeeh/k8s
   kubectl apply -f deployment.yaml
   kubectl apply -f service.yaml
   ```
2. Wait and run:
   ```bash
   kubectl get pods
   kubectl get services
   ```
3. Show output with pods in `Running` state and service showing `NodePort` on `30080`.
4. Open browser → navigate to `http://<EC2_PUBLIC_IP>:30080`.
5. Show the running application page with timestamp, container ID, and visitor counter.

---

### 03:30 – 04:00 | Refresh & Health Endpoint
**Voiceover:**
> "As you can see, the timestamp updates dynamically on every page refresh, confirming the application is live. Let's also verify the health check endpoint required by Kubernetes probes."

**Visuals (Screen Recording):**
1. Refresh the browser page 2-3 times.
2. Show the visitor counter incrementing.
3. Open a new tab: `http://<EC2_PUBLIC_IP>:30080/health`
4. Show JSON response:
   ```json
   {
     "status": "healthy",
     "timestamp": "2026-05-19T08:30:00.000Z",
     "uptime": 123.45
   }
   ```

---

### 04:00 – 04:30 | Scaling Demo
**Voiceover:**
> "One of Kubernetes' key features is horizontal scaling. Let's scale our deployment from one replica to two and observe the result."

**Visuals (Screen Recording):**
1. Terminal:
   ```bash
   kubectl scale deployment nodejs-app-deployment --replicas=2
   kubectl get pods -w
   ```
2. Show two pods running.
3. Run:
   ```bash
   kubectl get pods -o wide
   ```
4. Briefly mention that the Service load-balances between pods.

---

### 04:30 – 05:00 | Conclusion & Resource Termination
**Voiceover:**
> "In conclusion, this project successfully demonstrates containerizing a Node.js application with Docker, storing it in Amazon ECR, and deploying it on a Kubernetes cluster using Minikube on an EC2 t2.micro instance — all completely free within AWS Free Tier. I learned how container orchestration simplifies deployment and how cloud resources can be utilized cost-effectively. Finally, to ensure zero cost, I will now demonstrate the termination of resources."

**Visuals (Screen Recording):**
1. Terminal:
   ```bash
   kubectl delete -f deployment.yaml
   kubectl delete -f service.yaml
   minikube stop
   minikube delete
   ```
2. AWS Console → EC2 → Select instance → Instance state → Terminate.
3. AWS Console → ECR → Delete repository.
4. Final slide: "Thank you! Total Cost: $0.00"

---

## Recording Tips

- Use **OBS Studio** or **Zoom screen share recording** (free).
- Record at **1920x1080** resolution.
- Speak clearly and at a moderate pace.
- Keep the video **under 5 minutes** — practice once before final recording.
- Upload as **Unlisted** to YouTube or shareable link on Google Drive.

---

**Good Luck! 🎬**
