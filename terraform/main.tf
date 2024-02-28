

terraform {
    required_providers {
      aws = {
        source = "hashicorp/aws"
        version = "5.37.0"
	}
    null = {
      source = "hashicorp/null"
      version = "3.2.2"
    }
  }
  required_version = ">=1.0.0"
}

provider "aws" {
	region = "ap-south-1"
}

resource "aws_vpc" "pipeline_vpc" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "public_subnet" {
  vpc_id            = aws_vpc.pipeline_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "ap-south-1a"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "private_subnet" {
  vpc_id            = aws_vpc.pipeline_vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "ap-south-1a"
}

resource "aws_instance" "kube_argo_jump" {
  ami           = "ami-06b72b3b2a773be2b"
  instance_type = "t2.medium"
  subnet_id     = aws_subnet.public_subnet.id
  private_ip    = "10.0.1.5"  # Static private IP
  tags = {
    Name = "kube-argo-jump"
  }
	key_name = "20240228"
  	user_data = <<-EOF
              		#!/bin/bash
			wget -O /tmp/init.sh https://raw.githubusercontent.com/nahorov/ip-info-app/master/ansible/kube-argo-jump/init.sh
			chmod +x /tmp/init.sh
			sudo su -
			sh /tmp/init.sh
		       EOF
}

resource "aws_instance" "java_jenkins_maven" {
  ami           = "ami-06b72b3b2a773be2b"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.public_subnet.id
  private_ip    = "10.0.1.6"  # Static private IP
  tags = {
    Name = "java-jenkins-maven"
  }
  key_name = "20240228"
}

resource "aws_instance" "nexus" {
  ami           = "ami-06b72b3b2a773be2b"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.private_subnet.id
  private_ip    = "10.0.2.5"  # Static private IP
  tags = {
    Name = "nexus"
  }
  key_name = "20240228"
}

resource "aws_security_group" "pipeline_sg" {
  vpc_id = aws_vpc.pipeline_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 21
    to_port     = 21
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
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

resource "aws_route_table" "pipeline_route_table" {
  vpc_id = aws_vpc.pipeline_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.pipeline_igw.id
  }
}

resource "aws_route_table_association" "public_subnet_association" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.pipeline_route_table.id
}

resource "aws_route_table_association" "private_subnet_association" {
  subnet_id      = aws_subnet.private_subnet.id
  route_table_id = aws_route_table.pipeline_route_table.id
}

resource "aws_internet_gateway" "pipeline_igw" {
  vpc_id = aws_vpc.pipeline_vpc.id
}

