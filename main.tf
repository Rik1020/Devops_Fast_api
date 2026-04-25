provider "aws" {
  region = "ap-south-2"
}

# 🔹 Get latest Ubuntu AMI (no hardcoding)
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}

# VPC
resource "aws_vpc" "vpc" {
  cidr_block = "10.0.0.0/16"
}

# Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
}

# Route Table
resource "aws_route_table" "rt" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

# Subnet (IMPORTANT: specify AZ for ap-south-2)
resource "aws_subnet" "subnet" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "ap-south-2a"
  map_public_ip_on_launch = true
}

# Route Table Association
resource "aws_route_table_association" "rta" {
  subnet_id      = aws_subnet.subnet.id
  route_table_id = aws_route_table.rt.id
}

# Security Group
resource "aws_security_group" "sg" {
  vpc_id = aws_vpc.vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# EC2
resource "aws_instance" "ec2" {
  ami                    = data.aws_ami.ubuntu.id   # ✅ FIXED
  instance_type          = "t3.micro"
  key_name               = "my_key_1"               # must exist in ap-south-2
  vpc_security_group_ids = [aws_security_group.sg.id]
  subnet_id              = aws_subnet.subnet.id

  user_data = <<-EOF
              #!/bin/bash

              # Update system
              apt-get update -y

              # Install Docker
              apt-get install docker.io -y
              systemctl start docker
              systemctl enable docker

              # Install Python & pip
              apt-get install python3-pip -y

              # Install FastAPI & Uvicorn
              pip3 install fastapi uvicorn

              # Move to ec2 user home
              cd /home/ubuntu

              # Create FastAPI app
              cat <<EOT > main.py
from fastapi import FastAPI

app = FastAPI()

@app.get("/")
def home():
    return {"message": "FastAPI running via Terraform  - SUPRIYO 🚀"}

@app.get("/health")
def health():
    return {"status": "OK"}

@app.get("/hello/{name}")
def greet(name: str):
    return {"message": f"Hello {name}"}
EOT

              # Run app in background
              nohup uvicorn main:app --host 0.0.0.0 --port 8000 > app.log 2>&1 &
              EOF

  tags = {
    Name = "devops-ec2"
  }
  
}
output "app_url" {
  value = "http://${aws_instance.ec2.public_ip}:8000"
}
