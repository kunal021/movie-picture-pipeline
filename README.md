# Movie Picture Pipeline — CI/CD with GitHub Actions and AWS EKS

This repository contains the full automated CI/CD pipeline and Kubernetes manifests for the Movie Picture web application (React frontend and Flask backend), deployed on Amazon EKS.

## 🔗 Live Application URLs

- **Frontend Application**: [http://af1c634dbd2bb449ea8a66cbfbf41ccf-70307824.us-east-1.elb.amazonaws.com](http://af1c634dbd2bb449ea8a66cbfbf41ccf-70307824.us-east-1.elb.amazonaws.com)
- **Backend API (`/movies/`)**: [http://aef59347ee3f44a6ebe66cef939484cd-508910549.us-east-1.elb.amazonaws.com/movies/](http://aef59347ee3f44a6ebe66cef939484cd-508910549.us-east-1.elb.amazonaws.com/movies/)

---

## 🚀 GitHub Actions Workflows

All 4 required workflows are implemented and have successful runs in the [Actions](../../actions) tab:

| Workflow | File | Triggers | Jobs |
|---|---|---|---|
| **Frontend Continuous Integration** | `.github/workflows/frontend-ci.yaml` | PR to `main`, `workflow_dispatch` | `lint`, `test`, `build` |
| **Backend Continuous Integration** | `.github/workflows/backend-ci.yaml` | PR to `main`, `workflow_dispatch` | `lint`, `test`, `build` |
| **Frontend Continuous Deployment** | `.github/workflows/frontend-cd.yaml` | Push to `main`, `workflow_dispatch` | `lint`, `test`, `build` (ECR), `deploy` (EKS) |
| **Backend Continuous Deployment** | `.github/workflows/backend-cd.yaml` | Push to `main`, `workflow_dispatch` | `lint`, `test`, `build` (ECR), `deploy` (EKS) |

---

## ☸️ Kubernetes Deployment Status (`kubectl get all`)

```text
NAME                           READY   STATUS    RESTARTS   AGE
pod/backend-bdc4bfb4c-kdwhb    1/1     Running   0          5m
pod/frontend-7c975cf96-64jh5   1/1     Running   0          2m

NAME                 TYPE           CLUSTER-IP      EXTERNAL-IP                                                              PORT(S)        AGE
service/backend      LoadBalancer   172.20.28.241   aef59347ee3f44a6ebe66cef939484cd-508910549.us-east-1.elb.amazonaws.com   80:30959/TCP   5m
service/frontend     LoadBalancer   172.20.213.21   af1c634dbd2bb449ea8a66cbfbf41ccf-70307824.us-east-1.elb.amazonaws.com    80:32496/TCP   2m
service/kubernetes   ClusterIP      172.20.0.1      <none>                                                                   443/TCP        78m

NAME                       READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/backend    1/1     1            1           5m
deployment.apps/frontend   1/1     1            1           2m

NAME                                 DESIRED   CURRENT   READY   AGE
replicaset.apps/backend-bdc4bfb4c    1         1         1       5m
replicaset.apps/frontend-7c975cf96   1         1         1       2m
```

---

## 🛠️ Infrastructure Setup (Terraform)

Infrastructure was provisioned using Terraform in `setup/terraform/`:
- **VPC** with 2 public subnets across availability zones
- **Amazon EKS Cluster** (Kubernetes v1.30)
- **EKS Managed Node Group** (Free Tier eligible `t3.small` nodes)
- **Amazon ECR Repositories** for `frontend` and `backend` images
- Dedicated **IAM User** (`github-action-user`) with least-privilege policies for GitHub Actions CI/CD
