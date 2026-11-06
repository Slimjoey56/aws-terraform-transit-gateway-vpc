# AWS Multi-VPC Networking with Terraform

An infrastructure-as-code learning project that defines two Amazon VPCs, EC2 instances, route tables, and AWS Transit Gateway connectivity using Terraform.

## Architecture

The intended network has two VPCs:

| Component | Configuration |
|---|---|
| VPC 1 | `10.0.0.0/24` |
| Public subnet | `10.0.0.0/25` |
| VPC 2 | `20.0.0.0/24` |
| Private subnet | `20.0.0.0/25` |
| Connectivity | AWS Transit Gateway |

VPC 1 contains a public EC2 instance and an Internet Gateway. VPC 2 contains an EC2 instance without a public IP address. Route tables and Transit Gateway attachments are intended to support communication between the two networks.

## AWS Services and Tools

- Terraform
- Amazon VPC
- Amazon EC2
- AWS Transit Gateway
- Internet Gateway
- Route tables and security groups
- IAM instance profile
- EC2 user data

## Repository Contents

```text
.
├── main.tf
├── variables.tf
├── output.tf
├── .terraform.lock.hcl
├── .gitignore
└── README.md
```

## Requirements

- Terraform CLI
- AWS CLI
- An AWS account with appropriate permissions
- AWS credentials configured securely

Never commit AWS access keys, private keys, or Terraform state containing sensitive values.

## Usage

```bash
terraform init
terraform fmt
terraform validate
terraform plan
terraform apply
```

Review the plan carefully before applying it. AWS resources, including Transit Gateway and EC2, may incur charges.

To delete the provisioned resources:

```bash
terraform destroy
```

## Security Considerations

- Restrict inbound SSH to trusted addresses or use AWS Systems Manager.
- Apply least-privilege IAM permissions.
- Protect Terraform state.
- Review security group rules before deployment.
- Use environment-specific variables rather than hard-coded credentials.

## Limitations

This repository is an educational infrastructure example, not a production-ready network design. Deployment success, connectivity, and security have not been independently verified as part of this documentation update.

## Author

Jehosaphat Brobbey Impiani  
AWS Certified Solutions Architect – Associate  
[GitHub](https://github.com/Slimjoey56)