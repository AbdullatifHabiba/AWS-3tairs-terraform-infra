# DevOps Challenge - AWS Infrastructure

This Terraform configuration provisions a complete AWS infrastructure for a DevOps challenge, including frontend and backend EC2 instances, an RDS MySQL database, and CloudWatch monitoring with SNS alerts.

## 📑 Table of Contents

- [Architecture Overview](#-architecture-overview)
- [Infrastructure Components](#️-infrastructure-components)
  - [Network Architecture](#network-architecture)
  - [Compute Resources](#compute-resources)
  - [Database](#database)
  - [Security Groups](#security-groups)
  - [Monitoring](#monitoring)
- [Prerequisites](#-prerequisites)
- [Installation](#-installation)
- [Configuration](#️-configuration)
- [Outputs](#-outputs)
- [SSH Access](#-ssh-access)
- [Monitoring Setup](#-monitoring-setup)
- [File Structure](#️-file-structure)
- [Common Operations](#-common-operations)
- [Important Notes](#️-important-notes)
- [Troubleshooting](#️-troubleshooting)
- [CI/CD Integration](#-cicd-integration)
- [Migration Plan: AWS to Azure](#-migration-plan-aws-to-azure)
  - [Phase 1: Preparation & Planning](#phase-1-preparation--planning-week-1)
  - [Phase 2: Infrastructure Provisioning](#phase-2-infrastructure-provisioning-week-1-2)
  - [Phase 3: Data & Asset Migration](#phase-3-data--asset-migration-week-2)
  - [Phase 4: Application Deployment](#phase-4-application-deployment-week-2)
  - [Phase 5: Testing & Validation](#phase-5-testing--validation-week-3)
  - [Phase 6: DNS & Cutover Strategy](#phase-6-dns--cutover-strategy-week-3)
  - [Phase 7: Post-Migration](#phase-7-post-migration-week-4)
  - [Rollback Plan](#rollback-plan)
  - [Migration Timeline Summary](#migration-timeline-summary)
- [Additional Resources](#-additional-resources)
- [License](#-license)

---

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

## 🚀 CI/CD Integration

This infrastructure is integrated with GitHub Actions for automated deployments. The CI/CD pipelines automatically deploy applications to the EC2 instances when changes are pushed to the `main` branch.

### GitHub Actions Workflows

#### Backend Deployment (Laravel)

**Workflow File**: [backend-deploy.yml](https://github.com/AbdullatifHabiba/laravel/blob/main/.github/workflows/backend-deploy.yml)

**Triggers**:
- Push to `main` branch
- Manual workflow dispatch

**Deployment Steps**:
1. Connects to backend EC2 instance via SSH
2. Pulls latest code from repository
3. Installs/updates Composer dependencies
4. Runs database migrations (`php artisan migrate`)
5. Clears application cache
6. Restarts services

**Required Secrets**:
- `EC2_HOST`: Backend EC2 public IP
- `EC2_USER`: SSH username (ubuntu)
- `EC2_SSH_KEY`: Private SSH key for authentication

#### Frontend Deployment (Uptime Kuma)

**Workflow File**: [frontend-deploy.yml](https://github.com/AbdullatifHabiba/uptime-kuma/blob/main/.github/workflows/frontend-deploy.yml)

**Triggers**:
- Push to `main` branch
- Manual workflow dispatch

**Deployment Steps**:
1. Connects to frontend EC2 instance via SSH
2. Pulls latest code from repository
3. Builds Docker image
4. Deploys using Docker Compose
5. Restarts containers

**Required Secrets**:
- `EC2_HOST`: Frontend EC2 public IP
- `EC2_USER`: SSH username (ubuntu)
- `EC2_SSH_KEY`: Private SSH key for authentication

### Setting Up GitHub Secrets

After deploying the infrastructure with Terraform, configure GitHub repository secrets:

```bash
# Get the EC2 public IPs from Terraform outputs
terraform output frontend_public_ip
terraform output backend_public_ip

# Get the SSH private key
terraform output -raw private_key_pem > github-actions-key.pem
```

**Add secrets to GitHub**:
1. Navigate to your repository → Settings → Secrets and variables → Actions
2. Add the following secrets:
   - `EC2_HOST`: Use the output from `terraform output backend_public_ip` (for backend repo) or `frontend_public_ip` (for frontend repo)
   - `EC2_USER`: `ubuntu`
   - `EC2_SSH_KEY`: Paste the contents of `github-actions-key.pem`

### Manual Deployment Trigger

You can manually trigger deployments from the GitHub Actions tab:

1. Go to your repository → Actions
2. Select the workflow (backend-deploy or frontend-deploy)
3. Click "Run workflow"
4. Select the branch and click "Run workflow"

### Monitoring Deployments

View deployment status and logs:
- **GitHub Actions**: Repository → Actions tab
- **Application Logs**: SSH into instances and check logs
  ```bash
  # Backend logs
  ssh -i devops-challenge-key.pem ubuntu@$(terraform output -raw backend_public_ip)
  tail -f /var/www/laravel/storage/logs/laravel.log
  
  # Frontend logs
  ssh -i devops-challenge-key.pem ubuntu@$(terraform output -raw frontend_public_ip)
  docker-compose logs -f
  ```

---

## 🔄 Migration Plan: AWS to Azure

This section outlines a comprehensive strategy for migrating the infrastructure from AWS to Azure with **minimal downtime** and **zero data loss**.

### Migration Overview

**Objective**: Replicate the current AWS infrastructure on Azure and migrate all application data, database, and assets (images, PDFs, etc.) with minimal service interruption.

**Target Downtime**: < 30 minutes (during final cutover)

**Migration Strategy**: Blue-Green deployment with parallel infrastructure

---

### Phase 1: Preparation & Planning (Week 1)

#### 1.1 Infrastructure Assessment

- [ ] Document current AWS architecture and dependencies
- [ ] Inventory all application assets (storage locations, sizes, types)
- [ ] Identify database size, schema, and current load patterns
- [ ] Map AWS services to Azure equivalents:

| AWS Service | Azure Equivalent | Notes |
|-------------|------------------|-------|
| EC2 (t2.micro) | Azure VM (B1s) | 1 vCPU, 1GB RAM |
| RDS MySQL 8.0 | Azure Database for MySQL | Flexible Server |
| VPC | Virtual Network (VNet) | Similar networking model |
| Security Groups | Network Security Groups (NSG) | Port-based rules |
| CloudWatch | Azure Monitor | Metrics & alerts |
| SNS | Azure Monitor Action Groups | Email notifications |
| S3 (if used) | Azure Blob Storage | Object storage |

#### 1.2 Azure Account Setup

```bash
# Install Azure CLI
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

# Login to Azure
az login

# Create resource group
az group create --name devops-challenge-rg --location eastus

# Set default resource group
az configure --defaults group=devops-challenge-rg location=eastus
```

#### 1.3 Create Azure Terraform Configuration

Create a new directory `terraform-azure/` with equivalent infrastructure:

```hcl
# provider.tf
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}
}
```

**Key Azure Resources to Create**:
- Virtual Network with subnets
- 2 Linux VMs (Ubuntu 22.04)
- Azure Database for MySQL - Flexible Server
- Network Security Groups
- Azure Monitor alerts
- Action Groups for email notifications

---

### Phase 2: Infrastructure Provisioning (Week 1-2)

#### 2.1 Deploy Azure Infrastructure

```bash
cd terraform-azure/
terraform init
terraform plan -out=azure.tfplan
terraform apply azure.tfplan
```

#### 2.2 Configure VMs

```bash
# SSH into Azure VMs
ssh azureuser@<frontend-vm-ip>
ssh azureuser@<backend-vm-ip>

# Install Docker and Docker Compose on both VMs
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker $USER
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
```

#### 2.3 Setup Database Replication (Critical for Minimal Downtime)

**Option A: MySQL Replication (Recommended)**

```bash
# On AWS RDS - Enable binary logging (if not already enabled)
# Modify parameter group: binlog_format = ROW

# Create replication user on AWS
mysql -h <aws-rds-endpoint> -u admin -p
CREATE USER 'repl_user'@'%' IDENTIFIED BY 'SecurePassword123!';
GRANT REPLICATION SLAVE ON *.* TO 'repl_user'@'%';
FLUSH PRIVILEGES;

# On Azure MySQL - Configure as replica
# Set up replication from AWS RDS to Azure MySQL
CHANGE MASTER TO
  MASTER_HOST='<aws-rds-endpoint>',
  MASTER_USER='repl_user',
  MASTER_PASSWORD='SecurePassword123!',
  MASTER_LOG_FILE='mysql-bin.000001',
  MASTER_LOG_POS=154;

START SLAVE;
SHOW SLAVE STATUS\G
```

**Option B: Database Dump & Restore (Simpler, but requires downtime)**

```bash
# Dump from AWS RDS
mysqldump -h <aws-rds-endpoint> -u admin -p laraveldb > laraveldb_backup.sql

# Compress for faster transfer
gzip laraveldb_backup.sql

# Transfer to Azure VM
scp laraveldb_backup.sql.gz azureuser@<backend-vm-ip>:/tmp/

# Restore to Azure MySQL
gunzip laraveldb_backup.sql.gz
mysql -h <azure-mysql-endpoint> -u admin -p laraveldb < laraveldb_backup.sql
```

---

### Phase 3: Data & Asset Migration (Week 2)

#### 3.1 Migrate Application Assets

**Identify Asset Locations**:
```bash
# On AWS backend instance
ssh ubuntu@<aws-backend-ip>
find /var/www -type f \( -name "*.jpg" -o -name "*.png" -o -name "*.pdf" \)
du -sh /var/www/storage  # Check storage size
```

**Migration Methods**:

**Method 1: Direct rsync (Fastest for small to medium datasets)**

```bash
# From AWS backend to Azure backend
rsync -avz --progress \
  -e "ssh -i devops-challenge-key.pem" \
  ubuntu@<aws-backend-ip>:/var/www/storage/ \
  azureuser@<azure-backend-ip>:/var/www/storage/
```

**Method 2: Cloud Storage as Intermediary (For large datasets)**

```bash
# On AWS instance - Upload to Azure Blob Storage
az storage container create --name migration-assets
azcopy copy '/var/www/storage/*' \
  'https://<storage-account>.blob.core.windows.net/migration-assets' \
  --recursive

# On Azure instance - Download from Blob Storage
azcopy copy 'https://<storage-account>.blob.core.windows.net/migration-assets/*' \
  '/var/www/storage/' \
  --recursive
```

**Method 3: Incremental Sync (Minimal downtime)**

```bash
# Initial bulk transfer (while AWS is still live)
rsync -avz ubuntu@<aws-backend-ip>:/var/www/storage/ /tmp/storage-sync/

# During cutover - final incremental sync (only changed files)
rsync -avz --delete ubuntu@<aws-backend-ip>:/var/www/storage/ /tmp/storage-sync/
```

#### 3.2 Verify Data Integrity

```bash
# Generate checksums on source
ssh ubuntu@<aws-backend-ip>
find /var/www/storage -type f -exec md5sum {} \; > /tmp/aws-checksums.txt

# Generate checksums on destination
ssh azureuser@<azure-backend-ip>
find /var/www/storage -type f -exec md5sum {} \; > /tmp/azure-checksums.txt

# Compare checksums
diff /tmp/aws-checksums.txt /tmp/azure-checksums.txt
```

---

### Phase 4: Application Deployment (Week 2)

#### 4.1 Deploy Applications on Azure VMs

```bash
# Frontend (Uptime Kuma)
ssh azureuser@<azure-frontend-ip>
git clone <uptime-kuma-repo>
cd uptime-kuma
docker-compose up -d

# Backend (Laravel)
ssh azureuser@<azure-backend-ip>
git clone <laravel-repo>
cd laravel

# Update .env with Azure MySQL credentials
cp .env.example .env
nano .env
# DB_HOST=<azure-mysql-endpoint>
# DB_DATABASE=laraveldb
# DB_USERNAME=admin
# DB_PASSWORD=<password>

# Install dependencies and migrate
composer install
php artisan key:generate
php artisan migrate --force
php artisan storage:link
```

#### 4.2 Update CI/CD Pipelines

Update GitHub Actions workflows to support both AWS and Azure:

```yaml
# .github/workflows/deploy.yml
on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        environment: [aws, azure]  # Deploy to both during migration
    steps:
      - name: Deploy to ${{ matrix.environment }}
        run: |
          if [ "${{ matrix.environment }}" == "azure" ]; then
            ssh azureuser@${{ secrets.AZURE_BACKEND_IP }} "cd /app && git pull && php artisan migrate"
          else
            ssh ubuntu@${{ secrets.AWS_BACKEND_IP }} "cd /app && git pull && php artisan migrate"
          fi
```

---

### Phase 5: Testing & Validation (Week 3)

#### 5.1 Functional Testing

```bash
# Test frontend accessibility
curl -I http://<azure-frontend-ip>:3001

# Test backend API
curl http://<azure-backend-ip>/api/health

# Test database connectivity
mysql -h <azure-mysql-endpoint> -u admin -p -e "SELECT COUNT(*) FROM users;"
```

#### 5.2 Performance Testing

```bash
# Install Apache Bench
sudo apt-get install apache2-utils

# Load test backend
ab -n 1000 -c 10 http://<azure-backend-ip>/

# Compare with AWS performance
ab -n 1000 -c 10 http://<aws-backend-ip>/
```

#### 5.3 Data Validation

- [ ] Verify all database records migrated correctly
- [ ] Confirm all images/PDFs are accessible
- [ ] Test user authentication and sessions
- [ ] Validate application functionality end-to-end

---

### Phase 6: DNS & Cutover Strategy (Week 3)

#### 6.1 Pre-Cutover Checklist

- [ ] Azure infrastructure fully provisioned and tested
- [ ] Database replication lag < 1 second (if using replication)
- [ ] All application assets migrated and verified
- [ ] Applications deployed and functional on Azure
- [ ] Monitoring and alerts configured
- [ ] Rollback plan documented and tested
- [ ] Stakeholders notified of maintenance window

#### 6.2 Cutover Procedure (Minimal Downtime)

**Timeline: 30-minute maintenance window**

```bash
# T-0: Start maintenance window
# 1. Enable maintenance mode on AWS (2 minutes)
ssh ubuntu@<aws-backend-ip>
cd /var/www/laravel
php artisan down --message="System migration in progress"

# 2. Stop write operations to AWS database (1 minute)
# If using replication, wait for Azure to catch up
mysql -h <azure-mysql-endpoint> -u admin -p
SHOW SLAVE STATUS\G  # Verify Seconds_Behind_Master = 0

# 3. Final incremental asset sync (5 minutes)
rsync -avz --delete ubuntu@<aws-backend-ip>:/var/www/storage/ \
  azureuser@<azure-backend-ip>:/var/www/storage/

# 4. Stop replication and promote Azure MySQL to primary (2 minutes)
STOP SLAVE;
RESET SLAVE ALL;

# 5. Update DNS records (5 minutes)
# Point domain to Azure public IPs
# frontend.example.com -> <azure-frontend-ip>
# backend.example.com -> <azure-backend-ip>

# 6. Update application configurations (3 minutes)
# Update any hardcoded AWS endpoints to Azure

# 7. Bring Azure application online (2 minutes)
ssh azureuser@<azure-backend-ip>
php artisan up
php artisan cache:clear
php artisan config:clear

# 8. Verify services (5 minutes)
curl -I http://<azure-frontend-ip>:3001
curl http://<azure-backend-ip>/api/health

# 9. Monitor for errors (5 minutes)
tail -f /var/log/nginx/error.log
tail -f /var/www/laravel/storage/logs/laravel.log
```

#### 6.3 DNS Propagation Strategy

**Option 1: Low TTL (Recommended)**

```bash
# 24 hours before cutover - reduce DNS TTL to 300 seconds (5 minutes)
# This ensures faster propagation during cutover
```

**Option 2: Load Balancer / Traffic Manager**

```bash
# Use Azure Traffic Manager for gradual traffic shift
# Start with 10% traffic to Azure, monitor, then increase to 100%
```

---

### Phase 7: Post-Migration (Week 4)

#### 7.1 Monitoring & Validation

```bash
# Monitor Azure resources
az monitor metrics list --resource <vm-resource-id> --metric "Percentage CPU"

# Check application logs
ssh azureuser@<azure-backend-ip>
tail -f /var/www/laravel/storage/logs/laravel.log

# Verify database performance
mysql -h <azure-mysql-endpoint> -u admin -p
SHOW PROCESSLIST;
SHOW STATUS LIKE 'Threads_connected';
```

#### 7.2 Optimization

- [ ] Review and optimize Azure VM sizes based on actual usage
- [ ] Configure Azure CDN for static assets
- [ ] Setup Azure Backup for VMs and database
- [ ] Implement Azure Key Vault for secrets management
- [ ] Configure auto-scaling if needed

#### 7.3 Decommission AWS Resources

**Wait 2-4 weeks before decommissioning to ensure stability**

```bash
# Create final backup
aws rds create-db-snapshot --db-instance-identifier <rds-id> --db-snapshot-identifier final-backup

# Take AMI snapshots of EC2 instances
aws ec2 create-image --instance-id <instance-id> --name "final-backup-frontend"

# After validation period - destroy AWS infrastructure
cd terraform/
terraform destroy
```

---

### Rollback Plan

**If issues occur during cutover:**

```bash
# 1. Immediate rollback (< 5 minutes)
# Revert DNS to AWS IPs
# frontend.example.com -> <aws-frontend-ip>
# backend.example.com -> <aws-backend-ip>

# 2. Bring AWS application back online
ssh ubuntu@<aws-backend-ip>
php artisan up

# 3. Investigate issues on Azure
# Fix problems and schedule new cutover window
```

---

### Migration Timeline Summary

| Phase | Duration | Downtime | Key Activities |
|-------|----------|----------|----------------|
| **Preparation** | 3-5 days | None | Planning, Azure setup, Terraform config |
| **Infrastructure** | 2-3 days | None | Provision Azure resources, configure VMs |
| **Data Migration** | 3-5 days | None | Database replication, asset sync |
| **Testing** | 3-5 days | None | Functional, performance, data validation |
| **Cutover** | 30 min | **30 min** | DNS switch, final sync, go-live |
| **Post-Migration** | 2-4 weeks | None | Monitoring, optimization, AWS decommission |

**Total Timeline**: 3-4 weeks  
**Total Downtime**: < 30 minutes

---

### Cost Optimization Tips

1. **Use Azure Reserved Instances** for VMs (up to 72% savings)
2. **Enable Azure Hybrid Benefit** if you have Windows licenses
3. **Use Azure Blob Storage** cool tier for infrequently accessed assets
4. **Implement auto-shutdown** for non-production VMs
5. **Monitor with Azure Cost Management** to track spending

---

### Key Success Factors

✅ **Database replication** eliminates most downtime  
✅ **Incremental asset sync** reduces cutover time  
✅ **Parallel infrastructure** allows thorough testing  
✅ **Low DNS TTL** enables quick rollback  
✅ **Comprehensive testing** prevents surprises  
✅ **Clear rollback plan** reduces risk  

---

## 📚 Additional Resources

- [Terraform AWS Provider Documentation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [Terraform Azure Provider Documentation](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)
- [AWS to Azure Services Comparison](https://docs.microsoft.com/en-us/azure/architecture/aws-professional/services)
- [Azure Database Migration Guide](https://docs.microsoft.com/en-us/azure/dms/)
- [AWS EC2 Documentation](https://docs.aws.amazon.com/ec2/)
- [AWS RDS Documentation](https://docs.aws.amazon.com/rds/)
- [AWS CloudWatch Documentation](https://docs.aws.amazon.com/cloudwatch/)
- [Azure Virtual Machines Documentation](https://docs.microsoft.com/en-us/azure/virtual-machines/)
- [Azure Database for MySQL Documentation](https://docs.microsoft.com/en-us/azure/mysql/)

## 📝 License

This infrastructure code is provided as-is for the DevOps challenge.

---

**Created**: 2025-11-23  
**Terraform Version**: >= 1.0  
**AWS Provider Version**: ~> 5.0
