# Movie Picture Pipeline — CI/CD with GitHub Actions

A fully automated CI/CD pipeline for the Movie Picture web application using **GitHub Actions**, **Amazon ECR**, and **Amazon EKS**.

## Repository Structure

```
.
├── .github/
│   └── workflows/
│       ├── frontend-ci.yaml     # Frontend CI (PR → lint, test, build)
│       ├── frontend-cd.yaml     # Frontend CD (push main → ECR + EKS)
│       ├── backend-ci.yaml      # Backend CI  (PR → lint, test, build)
│       └── backend-cd.yaml      # Backend CD  (push main → ECR + EKS)
├── starter/
│   ├── frontend/                # React/TypeScript frontend app
│   │   ├── k8s/                 # Kubernetes manifests (kustomize)
│   │   └── Dockerfile
│   └── backend/                 # Python/Flask backend API
│       ├── k8s/                 # Kubernetes manifests (kustomize)
│       └── Dockerfile
└── setup/
    ├── init.sh                  # Grants GitHub Actions user EKS access
    └── terraform/               # AWS infrastructure as code
        ├── main.tf
        ├── variables.tf
        └── outputs.tf
```

## Applications

| App | Language | Framework | Port |
|-----|----------|-----------|------|
| Frontend | TypeScript | React | 3000 |
| Backend  | Python     | Flask | 5000 |

## Workflows Overview

| Workflow | File | Trigger | Jobs |
|----------|------|---------|------|
| Frontend Continuous Integration | `frontend-ci.yaml` | PR to `main` (frontend changes) | lint ∥ test → build |
| Frontend Continuous Deployment | `frontend-cd.yaml` | Push to `main` (frontend changes) | lint ∥ test → build+ECR push → deploy |
| Backend Continuous Integration | `backend-ci.yaml` | PR to `main` (backend changes) | lint ∥ test → build |
| Backend Continuous Deployment | `backend-cd.yaml` | Push to `main` (backend changes) | lint ∥ test → build+ECR push → deploy |

All workflows can also be triggered **manually** via `workflow_dispatch`.

## Required GitHub Secrets

Go to **Settings → Secrets and variables → Actions** and add:

| Secret | Description | Example |
|--------|-------------|---------|
| `AWS_ACCESS_KEY_ID` | github-action-user access key | `AKIAIOSFODNN7EXAMPLE` |
| `AWS_SECRET_ACCESS_KEY` | github-action-user secret key | `wJalrXUtnFEMI/...` |
| `AWS_REGION` | AWS region | `us-east-1` |
| `ECR_REGISTRY` | ECR registry base URL | `123456789.dkr.ecr.us-east-1.amazonaws.com` |
| `FRONTEND_ECR_REPO` | Frontend ECR repo name | `frontend` |
| `BACKEND_ECR_REPO` | Backend ECR repo name | `backend` |
| `EKS_CLUSTER_NAME` | EKS cluster name | `cluster` |
| `REACT_APP_MOVIE_API_URL` | Backend LoadBalancer URL | `http://<lb-hostname>` |

> ⚠️ **NEVER** put AWS credentials directly in workflow files. Always use secrets.

## Quick Start

### 1. Fork and clone

```bash
git clone https://github.com/<your-username>/cd12354-Movie-Picture-Pipeline.git
cd cd12354-Movie-Picture-Pipeline
```

### 2. Provision AWS infrastructure

See [TERRAFORM_SETUP.md](./TERRAFORM_SETUP.md) for full instructions.

```bash
cd setup/terraform
terraform init
terraform apply
```

### 3. Grant GitHub Actions user cluster access

```bash
cd setup
./init.sh cluster us-east-1
```

### 4. Add GitHub Secrets

Copy the Terraform outputs and add them as GitHub Secrets (see table above).

### 5. Deploy

- Open a PR against `main` → CI workflows run automatically
- Merge to `main` → CD workflows deploy to your cluster

## Local Development

### Frontend

```bash
cd starter/frontend
npm ci
REACT_APP_MOVIE_API_URL=http://localhost:5000 npm start
```

### Backend

```bash
cd starter/backend
pipenv install
pipenv run serve
```

### Run tests locally

```bash
# Frontend
cd starter/frontend && CI=true npm test

# Backend
cd starter/backend && pipenv run test
```

## Tear Down AWS Resources

```bash
cd setup/terraform
terraform destroy
```
