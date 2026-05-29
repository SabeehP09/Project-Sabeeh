# 🚀 Redeployment Guide for New Owner (SabeehP09)

> **Why you need this:** Transferring the GitHub repository does **not** transfer AWS infrastructure. The old EC2 instance, ECR registry, and public IP belonged to the previous owner's AWS account. You must redeploy on **your own AWS Free Tier account**.

---

## Prerequisites

| Tool | Check Version |
|------|---------------|
| AWS Account (Free Tier) | [aws.amazon.com/free](https://aws.amazon.com/free) |
| AWS CLI v2 | `aws --version` |
| Docker | `docker --version` |
| Git | `git --version` |

---

## Step 1: Configure AWS CLI Locally

```bash
aws configure
# Enter your AWS Access Key ID
# Enter your AWS Secret Access Key
# Enter your region (e.g., us-east-1)
# Enter output format: json
```

> Get credentials from AWS Console → IAM → Users → Security credentials → Create access key.

---

## Step 2: Clone the Repository

```bash
git clone https://github.com/SabeehP09/Project-Sabeeh.git
cd Project-Sabeeh
```

---

## Step 3: Build & Push Docker Image to YOUR ECR

```bash
cd scripts
./build-and-push.sh <YOUR_REGION> <YOUR_AWS_ACCOUNT_ID> nodejs-aws-k8s-app latest
```

**Example:**
```bash
./build-and-push.sh us-east-1 123456789012 nodejs-aws-k8s-app latest
```

You will see the pushed image URI at the end. Copy it — you'll need it for verification.

---

## Step 4: Launch EC2 Instance (t2.micro)

1. Go to [AWS Console → EC2](https://console.aws.amazon.com/ec2)
2. Click **Launch Instance**
3. **Name:** `minikube-k8s-node`
4. **AMI:** Amazon Linux 2023 (or Ubuntu Server 22.04 LTS)
5. **Instance Type:** `t2.micro` (Free Tier)
6. **Key Pair:** Create or select an existing `.pem` key pair
7. **Security Group:** Allow these inbound rules:
   - SSH (22) — from `0.0.0.0/0`
   - HTTP (80) — from `0.0.0.0/0`
   - Custom TCP (3000) — from `0.0.0.0/0`
8. **Storage:** 20 GB gp2
9. Click **Launch**
10. Copy the **Public IPv4 address** — this is your new app URL

---

## Step 5: Connect to EC2 & Run Setup

```bash
ssh -i your-key.pem ec2-user@<NEW_EC2_PUBLIC_IP>
# For Ubuntu, use: ubuntu@<NEW_EC2_PUBLIC_IP>
```

On the EC2 instance:
```bash
git clone https://github.com/SabeehP09/Project-Sabeeh.git
cd Project-Sabeeh/scripts
./setup-ec2.sh
```

> ⚠️ The script will add your user to the `docker` group. **Log out and SSH back in** for this to take effect.

---

## Step 6: Configure AWS CLI on EC2

```bash
aws configure
# Use the SAME credentials and region as Step 1
```

---

## Step 7: Deploy to Kubernetes

```bash
cd Project-Sabeeh/scripts
./deploy-k8s.sh <YOUR_REGION> <YOUR_AWS_ACCOUNT_ID> nodejs-aws-k8s-app latest
```

**Example:**
```bash
./deploy-k8s.sh us-east-1 123456789012 nodejs-aws-k8s-app latest
```

This script will:
1. Update `k8s/deployment.yaml` with your ECR image URI
2. Log in to ECR from EC2
3. Apply Kubernetes manifests
4. Wait for the deployment to be ready

---

## Step 8: Access Your Application

Open your browser and go to:

```
http://<NEW_EC2_PUBLIC_IP>:3000
```

You should see:
- ⏰ Live timestamp
- 🐳 Container ID
- 👥 Visitor counter

**Health check:**
```
http://<NEW_EC2_PUBLIC_IP>:3000/health
```

---

## Step 9: Update Project Docs (Important!)

Now that you have a new EC2 IP, update these files in your local repo before submitting:

1. `docs/REPORT.md` — Replace `<EC2_PUBLIC_IP>` placeholders with your actual IP in screenshots/descriptions
2. `docs/REPORT.html` — Same as above
3. `docs/VIDEO_SCRIPT.md` — Use your actual EC2 IP during screen recording
4. `screenshots/` — Take new screenshots with your new IP
5. `README.md` — Update the "Public Application URL" deliverable status

Then commit and push:
```bash
git add .
git commit -m "Updated deployment docs for new AWS infrastructure"
git push origin main
```

---

## Step 10: Cleanup (After Submission)

To avoid charges:

```bash
# On EC2
kubectl delete -f Project-Sabeeh/k8s/
minikube stop
minikube delete

# In AWS Console
# 1. Terminate the EC2 instance
# 2. Delete the ECR repository
# 3. Check Cost Explorer to confirm $0.00
```

---

## Troubleshooting

| Issue | Solution |
|-------|----------|
| `permission denied` for Docker | Run `sudo usermod -aG docker $USER` and re-login |
| `ImagePullBackOff` | Run `./deploy-k8s.sh` again — ECR login may have expired |
| Cannot access port 3000 | Open port 3000 in EC2 Security Group |
| Minikube won't start | Ensure Docker is running: `sudo systemctl start docker` |

---

**Good Luck! 🎓**
