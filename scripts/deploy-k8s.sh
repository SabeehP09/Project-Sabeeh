#!/bin/bash
# Deploy application to Minikube on EC2
# Run this on the EC2 instance after setup

set -e

REGION=${1:-us-east-1}
ACCOUNT_ID=${2:-YOUR_AWS_ACCOUNT_ID}
REPO_NAME=${3:-nodejs-aws-k8s-app}
IMAGE_TAG=${4:-latest}

echo "=========================================="
echo "Updating Kubernetes manifests with ECR image..."
echo "=========================================="

# Replace placeholder in deployment.yaml with actual ECR image
sed -i "s|YOUR_AWS_ACCOUNT_ID.dkr.ecr.YOUR_REGION.amazonaws.com/nodejs-aws-k8s-app:latest|$ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/$REPO_NAME:$IMAGE_TAG|g" ../k8s/deployment.yaml

echo "=========================================="
echo "Authenticating with ECR from EC2..."
echo "=========================================="
aws ecr get-login-password --region $REGION | docker login --username AWS --password-stdin $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com

echo "=========================================="
echo "Deploying to Kubernetes..."
echo "=========================================="
kubectl apply -f ../k8s/deployment.yaml
kubectl apply -f ../k8s/service.yaml

echo "=========================================="
echo "Waiting for deployment to be ready..."
echo "=========================================="
kubectl rollout status deployment/nodejs-app-deployment

echo "=========================================="
echo "Deployment Status:"
echo "=========================================="
kubectl get pods
kubectl get services

echo ""
echo "=========================================="
echo "Application should be accessible at:"
echo "  http://<EC2_PUBLIC_IP>:30080"
echo "=========================================="
