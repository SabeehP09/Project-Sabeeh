#!/bin/bash
# Build Docker image and push to Amazon ECR
# Usage: ./build-and-push.sh <aws-region> <account-id> <repository-name>

set -e

REGION=${1:-us-east-1}
ACCOUNT_ID=${2:-YOUR_AWS_ACCOUNT_ID}
REPO_NAME=${3:-nodejs-aws-k8s-app}
IMAGE_TAG=${4:-latest}

echo "=========================================="
echo "Configuration:"
echo "  Region: $REGION"
echo "  Account ID: $ACCOUNT_ID"
echo "  Repository: $REPO_NAME"
echo "  Tag: $IMAGE_TAG"
echo "=========================================="

# Login to Amazon ECR
echo "Logging in to Amazon ECR..."
aws ecr get-login-password --region $REGION | docker login --username AWS --password-stdin $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com

# Create ECR repository if it doesn't exist
echo "Creating ECR repository if not exists..."
aws ecr describe-repositories --repository-names $REPO_NAME --region $REGION || \
aws ecr create-repository --repository-name $REPO_NAME --region $REGION

# Build Docker image
echo "Building Docker image..."
docker build -t $REPO_NAME:$IMAGE_TAG ../

# Tag image for ECR
echo "Tagging image for ECR..."
docker tag $REPO_NAME:$IMAGE_TAG $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/$REPO_NAME:$IMAGE_TAG

# Push to ECR
echo "Pushing image to ECR..."
docker push $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/$REPO_NAME:$IMAGE_TAG

echo "=========================================="
echo "Image pushed successfully!"
echo "$ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/$REPO_NAME:$IMAGE_TAG"
echo "=========================================="
