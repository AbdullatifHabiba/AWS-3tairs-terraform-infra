# DevOps Challenge - AWS Infrastructure

This Terraform configuration provisions a complete AWS infrastructure for a DevOps challenge, including frontend and backend EC2 instances, an RDS MySQL database, and CloudWatch monitoring with SNS alerts.

## 📋 Architecture Overview

The infrastructure consists of:

- **VPC** with public and private subnets
- **2 EC2 Instances** (Ubuntu 22.04):
  - Frontend instance (Uptime Kuma)
  - Backend instance (Laravel)
- **RDS MySQL 8.0** database (private, not internet-accessible)
- **CloudWatch Alarms** for CPU monitoring (>50% threshold)
- **SNS Topic** for email alerts
- **Security Groups** with proper network isolation

## 🏗️ Infrastructure Components

### Network Architecture

- **VPC**: `10.0.0.0/16`
- **Public Subnet**: `10.0.1.0/24` (for EC2 instances)
- **Private Subnets**: `10.0.2.0/24` and `10.0.3.0/24` (for RDS)
- **Internet Gateway**: For public internet access
- **Route Tables**: Configured for public subnet routing

### Compute Resources

| Resource | Type | Specs | Network |
|----------|------|-------|---------|
| Frontend | EC2 t2.micro | 1 vCPU, 1GB RAM, 8GB disk | Public IP |
| Backend | EC2 t2.micro | 1 vCPU, 1GB RAM, 8GB disk | Public IP |

### Database

- **Engine**: MySQL 8.0
- **Instance Class**: db.t3.micro
- **Storage**: 20GB
- **Accessibility**: Private only (no public access)
- **Database Name**: `laraveldb`

### Security Groups

- **Frontend SG**: Allows HTTP (80), HTTPS (443), port 3001, and SSH (22)
- **Backend SG**: Allows HTTP (80) and SSH (22)
- **Database SG**: Allows MySQL (3306) only from backend security group

### Monitoring

- **CloudWatch Alarms**: CPU utilization monitoring for both instances
- **Threshold**: 50% average CPU over 2 evaluation periods (120s each)
- **Alerts**: Email notifications via SNS

## 🚀 Prerequisites

- [Terraform](https://www.terraform.io/downloads.html) >= 1.0
- AWS CLI configured with appropriate credentials
- AWS account with necessary permissions
- An AWS profile named `obedev` (or modify `aws_profile` variable)

## 📦 Installation

1. **Clone the repository** (if not already done):
   ```bash
   cd /path/to/terraform
   ```

2. **Initialize Terraform**:
   ```bash
   terraform init
   ```

3. **Review the planned changes**:
   ```bash
   terraform plan
   ```

4. **Apply the configuration**:
   ```bash
   terraform apply
   ```

## ⚙️ Configuration

### Required Variables

Create a `terraform.tfvars` file to customize your deployment:

```hcl
# AWS Configuration
aws_region  = "us-east-1"
aws_profile = "obedev"

# Network Configuration
vpc_cidr              = "10.0.0.0/16"
public_subnet_cidr    = "10.0.1.0/24"
private_subnet_cidr   = "10.0.2.0/24"
availability_zone     = "us-east-1a"

# Compute Configuration
instance_type = "t2.micro"
ami_id        = "ami-0c7217cdde317cfec"  # Ubuntu 22.04 LTS

# Database Configuration
db_username = "admin"
db_password = "YourSecurePassword123!"  # Change this!

# Security Configuration
my_ip = "YOUR.IP.ADDRESS/32"  # Your IP for SSH access

# Monitoring Configuration
alert_email = "your-email@example.com"
```

### Environment Variables (Recommended for Secrets)

For better security, pass sensitive variables via environment variables:

```bash
export TF_VAR_db_password="YourSecurePassword123!"
export TF_VAR_alert_email="your-email@example.com"
```

## 📤 Outputs

After successful deployment, Terraform will output:

- `frontend_public_ip`: Public IP address of the frontend instance
- `backend_public_ip`: Public IP address of the backend instance
- `db_endpoint`: RDS database connection endpoint
- `private_key_pem`: SSH private key (sensitive, use `terraform output -raw private_key_pem`)

### Accessing Outputs

```bash
# View all outputs
terraform output

# Get specific output
terraform output frontend_public_ip

# Save SSH key
terraform output -raw private_key_pem > devops-challenge-key.pem
chmod 400 devops-challenge-key.pem
```

## 🔐 SSH Access

The SSH key pair is automatically generated and saved as `devops-challenge-key.pem` in the terraform directory.

**Connect to instances**:

```bash
# Frontend instance
ssh -i devops-challenge-key.pem ubuntu@$(terraform output -raw frontend_public_ip)

# Backend instance
ssh -i devops-challenge-key.pem ubuntu@$(terraform output -raw backend_public_ip)
```

## 📊 Monitoring Setup

1. **Confirm SNS subscription**: After deployment, check your email for an SNS subscription confirmation
2. **Click the confirmation link** to start receiving alerts
3. **Test alerts**: You can manually trigger alarms from the AWS Console to verify email delivery

## 🗂️ File Structure

```
terraform/
├── provider.tf       # AWS provider configuration
├── variables.tf      # Input variable definitions
├── outputs.tf        # Output value definitions
├── network.tf        # VPC, subnets, security groups
├── compute.tf        # EC2 instances and SSH keys
├── database.tf       # RDS MySQL instance
├── monitoring.tf     # CloudWatch alarms and SNS
├── .gitignore        # Git ignore patterns
└── README.md         # This file
```

## 🔄 Common Operations

### Update Infrastructure

```bash
# Review changes
terraform plan

# Apply changes
terraform apply
```

### Destroy Infrastructure

```bash
# Destroy all resources
terraform destroy
```

### View Current State

```bash
# List all resources
terraform state list

# Show specific resource
terraform state show aws_instance.frontend
```

### Import Existing Resources

```bash
terraform import aws_instance.frontend i-1234567890abcdef0
```

## ⚠️ Important Notes

1. **Security**: Change the default `db_password` and `my_ip` variables before deployment
2. **Costs**: This infrastructure will incur AWS charges (EC2 + RDS + data transfer)
3. **SSH Key**: The private key is stored in state and as a local file - keep it secure
4. **State File**: Contains sensitive data - do not commit `terraform.tfstate` to version control
5. **Email Alerts**: You must confirm the SNS subscription via email to receive alerts

## 🛠️ Troubleshooting

### Issue: "Error creating DB Instance: InvalidParameterCombination"

**Solution**: Ensure your RDS instance class is available in your selected region/AZ.

### Issue: "Error launching source instance: InvalidAMIID.NotFound"

**Solution**: Update the `ami_id` variable with a valid Ubuntu 22.04 AMI for your region.

### Issue: SSH connection refused

**Solution**: 
- Verify security group allows your IP
- Check instance is running: `aws ec2 describe-instances`
- Ensure SSH key permissions: `chmod 400 devops-challenge-key.pem`

### Issue: Not receiving CloudWatch alerts

**Solution**: Confirm SNS subscription via the email link sent after deployment.

## 📚 Additional Resources

- [Terraform AWS Provider Documentation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [AWS EC2 Documentation](https://docs.aws.amazon.com/ec2/)
- [AWS RDS Documentation](https://docs.aws.amazon.com/rds/)
- [AWS CloudWatch Documentation](https://docs.aws.amazon.com/cloudwatch/)

## 📝 License

This infrastructure code is provided as-is for the DevOps challenge.

---

**Created**: 2025-11-23  
**Terraform Version**: >= 1.0  
**AWS Provider Version**: ~> 5.0
