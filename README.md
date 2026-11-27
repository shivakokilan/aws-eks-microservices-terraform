# Production Amazon EKS (Kubernetes) & Microservices CI/CD (Terraform)

Infrastructure as Code (IaC) template provisioning a production-ready **Amazon EKS Kubernetes cluster** with managed worker node groups, IAM OIDC provider for IRSA (IAM Roles for Service Accounts), KMS secrets encryption, and automated GitHub Actions CI/CD validation.

## Architecture Overview

```mermaid
flowchart LR
    subgraph CICD["1. DevOps & CI/CD Pipeline"]
        DEV["GitHub Repository<br/>(Terraform & Helm Charts)"] --> GHA["GitHub Actions CI/CD<br/>(Validate & Build)"]
        GHA --> ECR["Amazon ECR<br/>(Private Container Registry)"]
    end

    subgraph EKS["2. Amazon EKS Cluster (Multi-AZ Private Subnets)"]
        CP["EKS Control Plane<br/>(Managed & KMS Encrypted)"]
        NG["Managed Worker Node Group<br/>(Auto Scaling t3.medium)"]
        IRSA["IAM OIDC Provider<br/>(Least-Privilege Pod Roles)"]
        CP --- NG
        IRSA --- NG
    end

    subgraph Traffic["3. Ingress & Observability"]
        ALB["AWS Application Load Balancer"] --> NG
        NG --> CW["CloudWatch Container Insights"]
    end

    ECR ==>|Pulls Signed Images| NG
```

## Key Production Features
- **Zero-Trust Pod Security (IRSA):** Configures an IAM OpenID Connect (OIDC) provider so Kubernetes pods assume fine-grained IAM roles without static AWS credentials.
- **Envelope Encryption:** Encrypts Kubernetes secrets at rest using a dedicated customer-managed AWS KMS key with automatic rotation.
- **Private Container Registry:** Provisions an Amazon ECR repository with automatic image vulnerability scanning on push and lifecycle cleanup rules.
- **Auto-Scaling Compute:** Deploys Multi-AZ managed node groups with automated scaling guardrails and CloudWatch control-plane logging enabled.

## Quick Start

```bash
# 1. Initialize Terraform providers
terraform init

# 2. Preview EKS cluster and ECR infrastructure
terraform plan -var="cluster_name=prod-microservices-eks"

# 3. Deploy EKS infrastructure
terraform apply -auto-approve
```
