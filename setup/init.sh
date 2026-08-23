#!/bin/bash
# init.sh — Adds github-action-user to the Kubernetes aws-auth ConfigMap
# Run this ONCE after terraform apply to grant GitHub Actions access to EKS

set -e

CLUSTER_NAME="${1:-cluster}"
REGION="${2:-us-east-1}"

echo "==> Updating kubeconfig for cluster: $CLUSTER_NAME"
aws eks update-kubeconfig --name "$CLUSTER_NAME" --region "$REGION"

echo "==> Fetching github-action-user ARN..."
GITHUB_ACTION_USER_ARN=$(aws iam get-user --user-name github-action-user --query 'User.Arn' --output text)
echo "    User ARN: $GITHUB_ACTION_USER_ARN"

echo "==> Downloading AWS IAM Authenticator v0.6.2..."
curl -Lo aws-iam-authenticator \
  https://github.com/kubernetes-sigs/aws-iam-authenticator/releases/download/v0.6.2/aws-iam-authenticator_0.6.2_linux_amd64
chmod +x aws-iam-authenticator

echo "==> Adding $GITHUB_ACTION_USER_ARN to aws-auth ConfigMap..."
./aws-iam-authenticator add user \
  --userarn="$GITHUB_ACTION_USER_ARN" \
  --username="github-action-role" \
  --groups="system:masters" \
  --kubeconfig="$HOME/.kube/config" \
  --prompt=false

echo "==> Cleaning up..."
rm -f aws-iam-authenticator

echo "==> Done! github-action-user now has cluster access."
echo "    Verify with: kubectl get configmap aws-auth -n kube-system -o yaml"
