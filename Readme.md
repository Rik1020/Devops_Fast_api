# FastAPI Deployment using Docker and Terraform on AWS

## Project Overview

This project demonstrates the deployment of a FastAPI application on an AWS EC2 instance using Docker for containerization and Terraform for infrastructure provisioning. The application is publicly accessible via the EC2 instance.

---

## Architecture

User → EC2 Instance → Docker Container → FastAPI Application

---

## Technology Stack

* Python (FastAPI)
* Docker
* Terraform
* AWS EC2

---

## Project Structure

```
Devops_Fast_api/
│
├── main.py
├── Dockerfile
├── requirements.txt
├── main.tf
├── .gitignore
├── terraform.tfstate
├── terraform.tfstate.backup
├── .terraform/
└── terraform.lock.hcl
```

---

## Deployment Steps

### 1. Clone the Repository

```
git clone https://github.com/Rik1020/Devops_Fast_api.git
cd Devops_Fast_api
```

---

### 2. Build and Push Docker Image

```
docker build -t supriyokarmakar123/devops_fast_api:v1 .
docker push supriyokarmakar123/devops_fast_api:v1
```

---

### 3. Configure AWS Credentials

Ensure AWS CLI is configured:

```
aws configure
```

Provide:

* Access Key :AKIAXWSNUL5PMJCMNCGR
* Secret Key
* Region (e.g., ap-south-2)

---

### 4. Deploy Infrastructure using Terraform

```
terraform init
terraform apply
```

Confirm by typing `yes` when prompted.

---

### 5. Access the Application

After deployment, Terraform will output the application URL:

```
http://<EC2_PUBLIC_IP>:8000
```

---

## Updating the Application

When changes are made to the application:

1. Rebuild the Docker image

```
docker build -t supriyokarmakar123/devops_fast_api:v1 .
```

2. Push the updated image

```
docker push supriyokarmakar123/devops_fast_api:v1
```

3. Re-run Terraform or restart the container on the EC2 instance

---

## Branching Strategy

The repository follows a multi-environment branching approach:

* dev: Development environment
* qa: Testing and validation
* prod: Production environment

Code promotion flow:

```
dev → qa → prod
```

---

## Security Considerations

* Private key files (.pem) are excluded from version control
* Terraform state files are ignored using .gitignore
* The .terraform directory is not committed
* Security groups restrict access to required ports only

---

## Prerequisites

* Docker installed
* Terraform installed
* AWS account configured with credentials

---


---

## Author

Supriyo Karmakar
