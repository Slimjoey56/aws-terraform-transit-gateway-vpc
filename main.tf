terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.region
  # Authentication comes from the standard AWS credential chain:
  # environment, shared config, IAM Identity Center, or an attached IAM role.
}

data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

locals {
  availability_zone = data.aws_availability_zones.available.names[0]
  ami_id             = data.aws_ami.amazon_linux.id
}

resource "aws_vpc" "first_vpc" {
  cidr_block           = var.first_vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = { Name = "First_VPC" }
}

resource "aws_subnet" "public_subnet_first_vpc" {
  vpc_id                  = aws_vpc.first_vpc.id
  cidr_block              = cidrsubnet(var.first_vpc_cidr, 1, 0)
  availability_zone       = local.availability_zone
  map_public_ip_on_launch = true
  tags = { Name = "Public_subnet_first_VPC" }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.first_vpc.id
  tags   = { Name = "IGW" }
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.first_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = { Name = "PublicRT" }
}

resource "aws_route_table_association" "public_subnet_association" {
  subnet_id      = aws_subnet.public_subnet_first_vpc.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_security_group" "ec2sg" {
  name        = "whiz_sg"
  description = "Public web server; SSH is restricted to the configured admin CIDR."
  vpc_id      = aws_vpc.first_vpc.id

  dynamic "ingress" {
    for_each = var.admin_cidr == null ? [] : [var.admin_cidr]
    content {
      description = "SSH from trusted administrator CIDR only"
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = [ingress.value]
    }
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "whiz_sg" }
}

resource "aws_instance" "first_vpc_ec2" {
  ami                         = local.ami_id
  instance_type               = var.instance_type
  key_name                    = var.key_name
  vpc_security_group_ids      = [aws_security_group.ec2sg.id]
  subnet_id                   = aws_subnet.public_subnet_first_vpc.id
  associate_public_ip_address = true

  user_data = <<-EOF
    #!/bin/bash
    dnf update -y
    dnf install -y httpd
    systemctl enable --now httpd
    echo '<html><h1>Welcome to Whizlabs Public Server</h1></html>' > /var/www/html/index.html
  EOF

  tags = { Name = "First_VPC_EC2" }
}

resource "aws_vpc" "second_vpc" {
  cidr_block           = var.second_vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = { Name = "Second_VPC" }
}

resource "aws_subnet" "private_subnet_second_vpc" {
  vpc_id            = aws_vpc.second_vpc.id
  cidr_block        = cidrsubnet(var.second_vpc_cidr, 1, 0)
  availability_zone = local.availability_zone
  tags              = { Name = "Private_subnet_second_VPC" }
}

resource "aws_security_group" "privateec2sg" {
  name        = "whiz_sg2"
  description = "Private server; SSH allowed only from the first VPC CIDR."
  vpc_id      = aws_vpc.second_vpc.id

  ingress {
    description = "SSH from the connected first VPC only"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.first_vpc_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "whiz_sg2" }
}

resource "aws_instance" "second_vpc_ec2" {
  ami                         = local.ami_id
  instance_type               = var.instance_type
  key_name                    = var.key_name
  vpc_security_group_ids      = [aws_security_group.privateec2sg.id]
  subnet_id                   = aws_subnet.private_subnet_second_vpc.id
  associate_public_ip_address = false

  user_data = <<-EOF
    #!/bin/bash
    dnf update -y
    dnf install -y httpd
    systemctl enable --now httpd
    echo '<html><h1>Welcome to Whizlabs Private Server</h1></html>' > /var/www/html/index.html
  EOF

  tags = { Name = "Second_VPC_EC2" }
}

resource "aws_ec2_transit_gateway" "demo_tg" {
  description = "Transit Gateway connecting the two VPCs"
  tags        = { Name = "DemoTG" }
}

resource "aws_ec2_transit_gateway_vpc_attachment" "first_vpc_tga" {
  transit_gateway_id = aws_ec2_transit_gateway.demo_tg.id
  vpc_id             = aws_vpc.first_vpc.id
  subnet_ids         = [aws_subnet.public_subnet_first_vpc.id]
}

resource "aws_ec2_transit_gateway_vpc_attachment" "second_vpc_tga" {
  transit_gateway_id = aws_ec2_transit_gateway.demo_tg.id
  vpc_id             = aws_vpc.second_vpc.id
  subnet_ids         = [aws_subnet.private_subnet_second_vpc.id]
}

resource "aws_route" "first_vpc_route_to_second_vpc" {
  route_table_id         = aws_route_table.public_rt.id
  destination_cidr_block = var.second_vpc_cidr
  transit_gateway_id     = aws_ec2_transit_gateway.demo_tg.id
  depends_on             = [aws_ec2_transit_gateway_vpc_attachment.second_vpc_tga]
}

resource "aws_route" "second_vpc_route_to_first_vpc" {
  route_table_id         = aws_vpc.second_vpc.main_route_table_id
  destination_cidr_block = var.first_vpc_cidr
  transit_gateway_id     = aws_ec2_transit_gateway.demo_tg.id
  depends_on             = [aws_ec2_transit_gateway_vpc_attachment.first_vpc_tga]
}
