# AWS VPC Networking with Terraform

Infrastructure-as-Code project demonstrating AWS VPC networking, EC2 deployment, routing, and multi-VPC connectivity using an AWS Transit Gateway and Terraform.

## Overview

This project provisions two Amazon VPCs and connects them through an AWS Transit Gateway.

The first VPC contains a public subnet with an EC2 instance that receives a public IP address and is configured to run an Apache HTTP server.

The second VPC contains a private subnet with an EC2 instance that does not receive a public IP address.

An AWS Transit Gateway provides connectivity between the two VPCs, with route tables configured to direct traffic through the Transit Gateway.

## Architecture

```text
                         Internet
                            |
                    Internet Gateway
                            |
                    Public Route Table
                            |
                 ┌─────────────────────┐
                 │       VPC 1          │
                 │    10.0.0.0/24       │
                 │                     │
                 │ Public Subnet        │
                 │ 10.0.0.0/25         │
                 │       │              │
                 │   Public EC2         │
                 └───────┬─────────────┘
                         │
                         │
                  AWS Transit Gateway
                         │
                         │
                 ┌───────┴─────────────┐
                 │       VPC 2          │
                 │    20.0.0.0/24       │
                 │                     │
                 │ Private Subnet       │
                 │ 20.0.0.0/25         │
                 │       │              │
                 │   Private EC2        │
                 └─────────────────────┘
```

## Technologies

* AWS
* Terraform
* Amazon VPC
* Amazon EC2
* AWS Transit Gateway
* Internet Gateway
* Route Tables
* Security Groups
* Apache HTTP Server
* Infrastructure as Code (IaC)

## AWS Resources

The Terraform configuration creates:

### Networking

* 2 VPCs
* 1 public subnet
* 1 private subnet
* 1 Internet Gateway
* 1 public route table
* Route table associations
* AWS Transit Gateway
* 2 Transit Gateway VPC attachments
* Routes between the two VPCs

### Compute

* 1 public EC2 instance
* 1 private EC2 instance

Both EC2 instances use the `t2.micro` instance type.

### Security

The project creates separate security groups for the EC2 instances.

The public instance allows inbound traffic on:

* SSH — TCP 22
* HTTP — TCP 80
* HTTPS — TCP 443

The private instance allows SSH traffic.

> For production environments, SSH should not normally be exposed to `0.0.0.0/0`. Restrict SSH access to a trusted IP range or use a managed access solution such as AWS Systems Manager.

## Network Configuration

### VPC 1

| Component         | CIDR          |
| ----------------- | ------------- |
| VPC               | `10.0.0.0/24` |
| Public Subnet     | `10.0.0.0/25` |
| Availability Zone | `us-east-1a`  |

The public subnet is connected to the Internet Gateway through a public route table.

### VPC 2

| Component         | CIDR          |
| ----------------- | ------------- |
| VPC               | `20.0.0.0/24` |
| Private Subnet    | `20.0.0.0/25` |
| Availability Zone | `us-east-1a`  |

The private subnet does not assign a public IP address to its EC2 instance.

## Transit Gateway

The project uses an AWS Transit Gateway to provide connectivity between the two VPCs.

Each VPC is attached to the Transit Gateway:

```text
VPC 1
  |
  | Transit Gateway Attachment
  |
  v
AWS Transit Gateway
  |
  | Transit Gateway Attachment
  |
  v
VPC 2
```

Routes are configured so that traffic destined for the opposite VPC CIDR is forwarded through the Transit Gateway.

## EC2 Configuration

The public EC2 instance:

* Runs in VPC 1
* Runs in the public subnet
* Receives a public IP
* Uses an IAM instance profile
* Installs Apache using user data
* Starts the Apache service automatically

The private EC2 instance:

* Runs in VPC 2
* Runs in the private subnet
* Does not receive a public IP
* Installs Apache using user data

## Project Structure

```text
aws-terraform-transit-gateway-vpc/
│
├── main.tf
├── variables.tf
├── output.tf
├── .terraform.lock.hcl
├── terraform.tfvars.example
├── .gitignore
└── README.md
```

## Prerequisites

Before deploying the infrastructure, install:

1. Terraform
2. AWS CLI
3. An AWS account
4. Appropriate AWS IAM permissions
5. An existing EC2 key pair if SSH access is required

Verify Terraform:

```bash
terraform version
```

Verify AWS CLI:

```bash
aws --version
```

Configure AWS credentials securely:

```bash
aws configure
```

Do not store AWS access keys directly in a Git repository.

## Configuration

Create a local `terraform.tfvars` file:

```hcl
region = "us-east-1"
```

The credentials should be provided through AWS CLI configuration, environment variables, or another secure credential mechanism rather than committed to Terraform configuration.

## Deployment

Initialize Terraform:

```bash
terraform init
```

Format the configuration:

```bash
terraform fmt
```

Validate the configuration:

```bash
terraform validate
```

Review the planned infrastructure:

```bash
terraform plan
```

Deploy:

```bash
terraform apply
```

To remove the infrastructure:

```bash
terraform destroy
```

## Outputs

The configuration exposes outputs including:

* First VPC ID
* Second VPC ID
* Public subnet ID
* Private subnet ID
* Internet Gateway ID
* Public route table ID
* Public EC2 security group ID
* Private EC2 security group ID
* Public EC2 instance ID
* Public EC2 public IP
* Private EC2 instance ID
* Transit Gateway ID
* Transit Gateway attachment IDs

View outputs with:

```bash
terraform output
```

## Security Considerations

This project is intended as a learning and demonstration environment.

For production deployments, consider:

* Restricting SSH access instead of allowing `0.0.0.0/0`
* Using IAM roles instead of hard-coded AWS credentials
* Storing Terraform state in a secure remote backend
* Enabling encryption for Terraform state storage
* Using private subnets for workloads that do not require direct internet access
* Using AWS Systems Manager instead of direct SSH where appropriate
* Avoiding hard-coded AMI IDs
* Using variables for environment-specific configuration
* Implementing least-privilege IAM policies

## Key Learning Objectives

This project demonstrates practical understanding of:

* AWS VPC architecture
* Public and private subnets
* Internet Gateways
* Route tables
* EC2 networking
* Security Groups
* Transit Gateway
* Inter-VPC routing
* Terraform Infrastructure as Code
* Terraform variables and outputs
* Infrastructure deployment and management

## Disclaimer

This repository is a learning project created to demonstrate AWS networking and Terraform concepts. Infrastructure configuration should be reviewed and hardened before being used in a production environment.

## Author

**Jehosaphat Brobbey Impiani**
 Data Scientist | Machine Learning Engineer | AWS Cloud Practitioner

GitHub: `Slimjoey56`
