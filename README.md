# #ThreeTierApp

## Overview
This repository hosts the `#ThreeTierApp` in which web-app with Dockerized microservices pushed to ECR, deployed to EKS via Terraform. Jenkins handles CI/CD with SonarQube (code quality), Trivy (security scanning + email alerts), ArgoCD (GitOps), Prometheus & Grafana (monitoring), and Helm for Kubernetes deployments.

## Steps
- [Application Code](#application-code)
- [Jenkins Pipeline Code](#jenkins-pipeline-code)
- [Jenkins Server Terraform](#jenkins-server-terraform)
- [Kubernetes Manifests Files](#kubernetes-manifests-files)
- [Project Details](#project-details)

## Application Code
The `Application-Code` directory contains the source code for the Three-Tier Web Application. Dive into this directory to explore the frontend and backend implementations.

## Jenkins Pipeline Code
In the `Jenkins-Pipeline-Code` directory, you'll find Jenkins pipeline scripts. These scripts automate the CI/CD process, ensuring smooth integration and deployment of your application.

## Jenkins Server Terraform
Explore the `Jenkins-Server-TF` directory to find Terraform scripts for setting up the Jenkins Server on AWS. These scripts simplify the infrastructure provisioning process.

## Kubernetes Manifests Files
The `Kubernetes-Manifests-Files` directory holds Kubernetes manifests for deploying your application on AWS EKS. Understand and customize these files to suit your project needs.

## Project Details
🛠️ **Tools Explored:**
- Terraform & AWS CLI for AWS infrastructure
- Jenkins, Sonarqube, Terraform, Kubectl, and more for CI/CD setup
- Helm, Prometheus, and Grafana for Monitoring
- ArgoCD for GitOps practices

🚢 **High-Level Overview:**
- IAM User setup & Terraform magic on AWS
- Jenkins deployment with AWS integration
- EKS Cluster creation & Load Balancer configuration
- Private ECR repositories for secure image management
- Helm charts for efficient monitoring setup
- GitOps with ArgoCD - the cherry on top!

📈 **The journey covered everything from setting up tools to deploying a Three-Tier app, ensuring data persistence, and implementing CI/CD pipelines.**

## Getting Started
To get started with this project, refer to our [comprehensive guide](https://amanpathakdevops.medium.com/advanced-end-to-end-devsecops-kubernetes-three-tier-project-using-aws-eks-argocd-prometheus-fbbfdb956d1a) that walks you through IAM user setup, infrastructure provisioning, CI/CD pipeline configuration, EKS cluster creation, and more.

### Step 1: IAM Configuration
- Create a user `eks-admin` with `AdministratorAccess`.
- Generate Security Credentials: Access Key and Secret Access Key.

### Step 2: EC2 Setup
- Launch an Ubuntu instance in your favourite region (eg. region `us-west-2`).
- SSH into the instance from your local machine.

### Step 3: Install AWS CLI v2
``` shell
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
sudo apt install unzip
unzip awscliv2.zip
sudo ./aws/install -i /usr/local/aws-cli -b /usr/local/bin --update
aws configure
```

### Step 4: Install Docker
``` shell
sudo apt-get update
sudo apt install docker.io
docker ps
sudo chown $USER /var/run/docker.sock
```

### Step 5: Install kubectl
``` shell
curl -o kubectl https://amazon-eks.s3.us-west-2.amazonaws.com/1.19.6/2021-01-05/bin/linux/amd64/kubectl
chmod +x ./kubectl
sudo mv ./kubectl /usr/local/bin
kubectl version --short --client
```

### Step 6: Install eksctl
``` shell
curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
sudo mv /tmp/eksctl /usr/local/bin
eksctl version
```

### Step 7: Setup EKS Cluster
``` shell
eksctl create cluster --name three-tier-cluster --region us-west-2 --node-type t2.medium --nodes-min 2 --nodes-max 2
aws eks update-kubeconfig --region us-west-2 --name three-tier-cluster
kubectl get nodes
```

### Step 8: Run Manifests
``` shell
kubectl create namespace workshop
kubectl apply -f .
kubectl delete -f .
```

### Step 9: Install AWS Load Balancer
``` shell
curl -O https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.5.4/docs/install/iam_policy.json
aws iam create-policy --policy-name AWSLoadBalancerControllerIAMPolicy --policy-document file://iam_policy.json
eksctl utils associate-iam-oidc-provider --region=us-west-2 --cluster=three-tier-cluster --approve
eksctl create iamserviceaccount --cluster=three-tier-cluster --namespace=kube-system --name=aws-load-balancer-controller --role-name AmazonEKSLoadBalancerControllerRole --attach-policy-arn=arn:aws:iam::626072240565:policy/AWSLoadBalancerControllerIAMPolicy --approve --region=us-west-2
```

### Step 10: Deploy AWS Load Balancer Controller
``` shell
sudo snap install helm --classic
helm repo add eks https://aws.github.io/eks-charts
helm repo update eks
helm install aws-load-balancer-controller eks/aws-load-balancer-controller -n kube-system --set clusterName=my-cluster --set serviceAccount.create=false --set serviceAccount.name=aws-load-balancer-controller
kubectl get deployment -n kube-system aws-load-balancer-controller
kubectl apply -f full_stack_lb.yaml
```
# Kubernetes Custom Host Access on Localhost — Complete Guide

This guide outlines the **exact steps, paths, and configurations** you applied to access your EKS-deployed frontend/backend apps using custom hostnames like `frontend.three-tier-huzaifa-app` on your **local machine**.

---

## ✅ Purpose

To access your Kubernetes applications using **custom hostnames** (instead of long ELB URLs), directly from your **local computer** (not the EC2 instance), by mapping domains to the AWS Load Balancer IPs.

---

## 🧩 Step-by-Step Process

### 🔍 1. Get ALB DNS Name (with hash)

To get the Load Balancer DNS created by AWS ALB Ingress Controller:

```bash
kubectl get ingress -n three-tier
```

Example output:

```bash
NAME      CLASS    HOSTS                                ADDRESS                                                               PORTS   AGE
mainlb    alb      frontend.three-tier-huzaifa-app       k8s-threetie-mainlb-b5b9250791-1087900858.ap-south-1.elb.amazonaws.com   80      5m
          backend.three-tier-huzaifa-app
```

The highlighted part is the DNS of your Application Load Balancer.

---

### 🌐 2. Find the Load Balancer IP Address

Use `nslookup` or `dig`:

```bash
nslookup k8s-threetie-mainlb-<hash>.ap-south-1.elb.amazonaws.com
```

Or:

```bash
dig +short k8s-threetie-mainlb-<hash>.ap-south-1.elb.amazonaws.com
```

Example result:

```
3.108.19.95
35.154.73.129
```

---

### ✏️ 3. Edit Local Hosts File

**Path:** `/etc/hosts`

**Command:**

```bash
sudo nano /etc/hosts
```

**Add lines at the bottom:**

```ini
35.154.73.129   frontend.three-tier-huzaifa-app
35.154.73.129   backend.three-tier-huzaifa-app
```

📝 This maps your domain to the Load Balancer IP address for your machine.

---

### ⚙️ 4. Configure Ingress Rules

**File:**
`~/Three-Tier-K8s-CI-CD-Infrastructure-GitOps/Kubernetes-Manifests-file/ingress.yml`

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: mainlb
  namespace: three-tier
  annotations:
    alb.ingress.kubernetes.io/scheme: internet-facing
    alb.ingress.kubernetes.io/target-type: ip
    alb.ingress.kubernetes.io/listen-ports: '[{"HTTP": 80}]'
spec:
  ingressClassName: alb
  rules:
    - host: frontend.three-tier-huzaifa-app
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: frontend
                port:
                  number: 3000

    - host: backend.three-tier-huzaifa-app
      http:
        paths:
          - path: /api
            pathType: Prefix
            backend:
              service:
                name: api
                port:
                  number: 3500
```

---

### 🚀 5. Test Locally

From your **local machine**, test with:

```bash
curl http://frontend.three-tier-huzaifa-app
curl http://backend.three-tier-huzaifa-app/api/tasks
```

Or open in a **browser**:

* `http://frontend.three-tier-huzaifa-app`
* `http://backend.three-tier-huzaifa-app/api/tasks`

---

## 🧠 Summary (Cheat Sheet)

| Step | What You Did                | Tool / File           |
| ---- | --------------------------- | --------------------- |
| 1    | Got Load Balancer DNS       | `kubectl get ingress` |
| 2    | Got LB IP                   | `nslookup`, `dig`     |
| 3    | Mapped host to IP           | `/etc/hosts`          |
| 4    | Configured hostname routing | `ingress.yml`         |
| 5    | Accessed app via hostname   | Browser / curl        |

---

> ✅ I updated my `/etc/hosts` file on my **local machine** to access the application using custom hostnames.

> 🔑 To get the hash-based DNS of the ALB (`k8s-threetie-mainlb-<hash>.elb.amazonaws.com`), I used:
>
> ```bash
> kubectl get ingress -n three-tier
> ```


### Cleanup
- To delete the EKS cluster:
``` shell
eksctl delete cluster --name three-tier-cluster --region us-west-2
```
- To clean up rest of the stuff and not incure any cost
```
Stop or Terminate the EC2 instance created in step 2.
Delete the Load Balancer created in step 9 and 10.
Go to EC2 console, access security group section and delete security groups created in previous steps
```

