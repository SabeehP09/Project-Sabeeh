#!/bin/bash
# EC2 Setup Script for Minikube, Docker, and AWS CLI
# Run this on your EC2 t2.micro instance (Amazon Linux 2023 / Ubuntu)

set -e

echo "=========================================="
echo "Updating system packages..."
echo "=========================================="
if command -v apt-get &> /dev/null; then
    sudo apt-get update -y
    sudo apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release conntrack
elif command -v yum &> /dev/null; then
    sudo yum update -y
    sudo yum install -y conntrack curl
fi

echo "=========================================="
echo "Installing Docker..."
echo "=========================================="
if command -v apt-get &> /dev/null; then
    sudo install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt-get update -y
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
elif command -v yum &> /dev/null; then
    sudo yum install -y docker
fi

sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker $USER
newgrp docker || true

echo "=========================================="
echo "Installing kubectl..."
echo "=========================================="
curl -LO "https://dl.k8s/release/$(curl -L -s https://dl.k8s/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
rm -f kubectl

echo "=========================================="
echo "Installing Minikube..."
echo "=========================================="
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube
rm -f minikube-linux-amd64

echo "=========================================="
echo "Installing AWS CLI v2..."
echo "=========================================="
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip -o awscliv2.zip
sudo ./aws/install --update
rm -rf awscliv2.zip aws/

echo "=========================================="
echo "Starting Minikube cluster..."
echo "=========================================="
minikube start --driver=docker --nodes=1

echo "=========================================="
echo "Verifying installations..."
echo "=========================================="
docker --version
kubectl version --client
minikube version
aws --version

echo "=========================================="
echo "EC2 Setup Complete!"
echo "=========================================="
