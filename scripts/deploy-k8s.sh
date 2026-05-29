#!/bin/bash
# Deploy application to Minikube on EC2
# Run this on the EC2 instance after setup

set -euo pipefail

REGION=${1:-us-east-1}
ACCOUNT_ID=${2:-YOUR_AWS_ACCOUNT_ID}
REPO_NAME=${3:-nodejs-aws-k8s-app}
IMAGE_TAG=${4:-latest}

echo "=========================================="
echo "Updating Kubernetes manifests with ECR image..."
echo "=========================================="

if [[ "$ACCOUNT_ID" == "YOUR_AWS_ACCOUNT_ID" || "$ACCOUNT_ID" == "" ]]; then
  echo "ERROR: AWS Account ID is required."
  exit 1
fi

if [[ "$REGION" == "YOUR_REGION" || "$REGION" == "" ]]; then
  echo "ERROR: AWS region is required."
  exit 1
fi

if [[ ! "$ACCOUNT_ID" =~ ^[0-9]{12}$ ]]; then
  echo "WARNING: AWS Account ID does not look like a 12-digit account number."
fi

ECR_IMAGE="$ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/$REPO_NAME:$IMAGE_TAG"
sed -i "s|^\(\s*image:\s*\).*|\1$ECR_IMAGE|" ../k8s/deployment.yaml

if [[ "$REGION" =~ ^[a-z]{2}-[a-z]+-[0-9][a-z]$ ]]; then
  echo "WARNING: '$REGION' looks like an availability zone, not a region."
  echo "Please use a region like 'us-east-1'."
fi

echo "=========================================="
echo "Authenticating with ECR from EC2..."
echo "=========================================="
ECR_PASSWORD=$(aws ecr get-login-password --region $REGION)
docker login --username AWS --password-stdin $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com <<< "$ECR_PASSWORD"

echo "=========================================="
echo "Creating Kubernetes image pull secret..."
echo "=========================================="
kubectl create secret docker-registry ecr-secret \
  --docker-server=$ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com \
  --docker-username=AWS \
  --docker-password="$ECR_PASSWORD" \
  --docker-email=none \
  --dry-run=client -o yaml | kubectl apply -f -

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
echo "  http://<EC2_PUBLIC_IP>:3000"
echo "=========================================="
