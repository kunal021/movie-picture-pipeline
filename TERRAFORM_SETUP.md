# Terraform Setup Guide — AWS Infrastructure for Movie Picture Pipeline

This guide walks you through provisioning the AWS infrastructure needed for the CI/CD pipeline.

## What Gets Created

| Resource | Type | Description |
|----------|------|-------------|
| VPC | `aws_vpc` | Isolated network with 2 public subnets |
| EKS Cluster | `aws_eks_cluster` | Kubernetes cluster (v1.27) |
| EKS Node Group | `aws_eks_node_group` | 2× `t3.medium` worker nodes |
| ECR Repository | `aws_ecr_repository` | `frontend` — stores frontend Docker images |
| ECR Repository | `aws_ecr_repository` | `backend` — stores backend Docker images |
| IAM User | `aws_iam_user` | `github-action-user` — used by GitHub Actions |
| IAM Policy | `aws_iam_policy` | ECR push + EKS describe permissions |

---

## Prerequisites

- AWS CLI configured with administrator credentials
- Terraform >= 1.3.9 (use `tfenv` or `tfswitch` to manage versions)

### Install tfenv (Linux/macOS/WSL)

```bash
git clone https://github.com/tfutils/tfenv.git ~/.tfenv
export PATH="$HOME/.tfenv/bin:$PATH"
source ~/.bashrc
tfenv install 1.3.9
tfenv use 1.3.9
```

---

## Step 1 — Create an Administrator IAM User

> This step is required because Udacity-managed AWS accounts (voclabs) have limited IAM permissions.

1. Open the AWS IAM console
2. Create a new user (e.g., `my-admin-user`)
3. Attach the **AdministratorAccess** managed policy
4. Under **Security credentials**, create an access key
5. Save the key ID and secret

---

## Step 2 — Configure AWS Credentials

```bash
export AWS_ACCESS_KEY_ID=<your-admin-access-key>
export AWS_SECRET_ACCESS_KEY=<your-admin-secret-key>
export AWS_DEFAULT_REGION=us-east-1
```

---

## Step 3 — Initialize and Apply Terraform

```bash
cd setup/terraform
terraform init
terraform plan      # Review what will be created
terraform apply     # Type 'yes' when prompted
```

Terraform will output values like:

```
cluster_name          = "cluster"
cluster_endpoint      = "https://..."
ecr_registry          = "123456789.dkr.ecr.us-east-1.amazonaws.com"
frontend_ecr_repo_url = "123456789.dkr.ecr.us-east-1.amazonaws.com/frontend"
backend_ecr_repo_url  = "123456789.dkr.ecr.us-east-1.amazonaws.com/backend"
github_action_user_arn = "arn:aws:iam::123456789:user/github-action-user"
```

> You can retrieve outputs later with: `terraform output`

---

## Step 4 — Generate GitHub Actions Access Keys

1. Go to IAM → Users → `github-action-user`
2. Open the **Security credentials** tab
3. Click **Create access key** → select "Application running outside AWS"
4. Copy the **Access Key ID** and **Secret Access Key**

These are the credentials you'll store as GitHub Secrets (`AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY`).

---

## Step 5 — Update kubeconfig and Grant EKS Access

```bash
# Update local kubeconfig
aws eks update-kubeconfig --name cluster --region us-east-1

# Verify connectivity
kubectl get nodes

# Run the init script to grant github-action-user cluster access
cd setup
./init.sh cluster us-east-1
```

---

## Step 6 — Add GitHub Secrets

In your GitHub repository: **Settings → Secrets and variables → Actions → New repository secret**

| Secret Name | Where to Get Value |
|-------------|-------------------|
| `AWS_ACCESS_KEY_ID` | Step 4 above |
| `AWS_SECRET_ACCESS_KEY` | Step 4 above |
| `AWS_REGION` | `us-east-1` |
| `ECR_REGISTRY` | Terraform output: `ecr_registry` |
| `FRONTEND_ECR_REPO` | `frontend` |
| `BACKEND_ECR_REPO` | `backend` |
| `EKS_CLUSTER_NAME` | `cluster` |
| `REACT_APP_MOVIE_API_URL` | Backend LoadBalancer URL (set after first backend deploy) |

---

## Step 7 — Get Backend LoadBalancer URL (after first deploy)

After the backend CD workflow runs for the first time:

```bash
kubectl get svc backend
# Copy the EXTERNAL-IP value, e.g. a1b2c3d4.us-east-1.elb.amazonaws.com
```

Set `REACT_APP_MOVIE_API_URL` = `http://<EXTERNAL-IP>` in GitHub Secrets, then re-run the frontend CD workflow.

---

## Tear Down

```bash
cd setup/terraform
terraform destroy
# Type 'yes' when prompted
```

> ⚠️ **Always tear down resources after the project to avoid unexpected AWS charges.**
