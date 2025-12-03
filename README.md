# AWS Infrastructure with Terraform

This Terraform project deploys a complete AWS infrastructure including VPC, EC2 instance, and a Dockerized Nginx web server.

## 📋 Overview

This infrastructure includes:
- **VPC** with public subnet (using official AWS VPC module)
- **Internet Gateway** for internet connectivity
- **Security Group** with SSH and HTTP (port 8080) access
- **EC2 Instance** (Amazon Linux 2023) with Docker
- **Nginx Web Server** running in a Docker container
- **S3 Backend** for remote state management

## 🏗️ Architecture

```
VPC (10.0.0.0/16)
  └── Public Subnet (10.0.10.0/24)
      ├── Internet Gateway
      ├── Security Group (SSH:22, HTTP:8080)
      └── EC2 Instance (t3.micro)
          └── Docker Container (Nginx on port 8080)
```

## 📁 Project Structure

```
.
├── main.tf                    # Main Terraform configuration
├── variables.tf               # Variable declarations
├── outputs.tf                 # Output values
├── terraform.tfvars           # Variable values (sensitive - not in git)
├── providers.tf               # Provider configuration
├── entry-script.sh            # EC2 initialization script
└── modules/
    └── webserver/             # Webserver module
        ├── main.tf            # EC2 instance and security group
        ├── variables.tf       # Module variables
        └── outputs.tf         # Module outputs
```

## 🚀 Prerequisites

- [Terraform](https://www.terraform.io/downloads.html) >= 1.0.0
- [AWS CLI](https://aws.amazon.com/cli/) configured with credentials
- SSH key pair (Ed25519 or RSA)
- S3 bucket for state storage

## ⚙️ Configuration

### 1. Update `terraform.tfvars`

```hcl
vpc_cidr_block    = "10.0.0.0/16"
subnet_cidr_block = "10.0.10.0/24"
env_prefix        = "dev"
az                = "ap-southeast-1a"
my_ip             = "YOUR_IP/32"              # Replace with your IP
instance_type     = "t3.micro"
public_key_path   = "~/.ssh/id_ed25519.pub"   # Path to your public key
private_key_path  = "~/.ssh/id_ed25519"       # Path to your private key
ami_name          = "al2023-ami-2023*-x86_64"
```

**Important:** Change `my_ip` from `0.0.0.0/0` to your specific IP address for better security.

### 2. Configure S3 Backend

Ensure you have an S3 bucket created:

```bash
aws s3 mb s3://abstraxlk-tf-state --region ap-southeast-1
```

## 🎯 Usage

### Initialize Terraform

```bash
terraform init
```

### Validate Configuration

```bash
terraform validate
```

### Plan Infrastructure

```bash
terraform plan
```

### Apply Configuration

```bash
terraform apply
```

Type `yes` when prompted to confirm.

### Destroy Infrastructure

```bash
terraform destroy
```

Type `yes` when prompted to confirm.

**Note:** If you encounter dependency errors during destroy (related to Internet Gateway or Subnet), wait 1-2 minutes for AWS to clean up Elastic Network Interfaces, then run `terraform destroy` again.

## 📤 Outputs

After successful deployment, you'll see:

- **ami_id**: The AMI ID used for the EC2 instance
- **ec2_public_ip**: The public IP address of your EC2 instance

## 🌐 Accessing the Web Server

Once deployed, access your Nginx server at:

```
http://<ec2_public_ip>:8080
```

You should see a custom welcome page with the server's hostname.

## 🔐 SSH Access

Connect to your EC2 instance:

```bash
ssh -i ~/.ssh/id_ed25519 ec2-user@<ec2_public_ip>
```

## 📝 What Gets Installed

The `entry-script.sh` provisions the EC2 instance with:

1. System updates (yum update)
2. Docker installation
3. Docker service start and enable
4. Nginx Docker container on port 8080
5. Custom HTML page with hostname

## 🛠️ Customization

### Change Instance Type

Edit `terraform.tfvars`:
```hcl
instance_type = "t3.small"  # or t3.medium, etc.
```

### Change Region

Edit `main.tf` backend and provider configuration, and update `az` in `terraform.tfvars`.

### Modify Security Rules

Edit `modules/webserver/main.tf` to add/remove security group rules.

## ⚠️ Known Issues

### AMI Version Changes
The EC2 AMI uses `most_recent = true`, which means Terraform may detect changes when AWS releases new AMI versions. To prevent unwanted instance replacements, you can:

1. Pin to a specific AMI ID
2. Add lifecycle policy to ignore AMI changes

### Docker Permission Error
If you see a Docker permission error, the script now uses `sudo docker run` to bypass group membership issues that occur during provisioning.

### Line Ending Issues (Windows)
The provisioner automatically converts Windows (CRLF) to Linux (LF) line endings using `sed` before executing scripts.

## 🔄 State Management

This project uses **S3 remote backend** for state storage:
- Bucket: `bucket-name`
- Key: `my-bucket/state.tfstate`
- Region: `ap-southeast-1`

Benefits:
- Team collaboration
- State locking (with DynamoDB - optional)
- Version history
- Secure storage

## 📚 Resources Created

- `aws_vpc` - VPC using terraform-aws-modules/vpc/aws
- `aws_subnet` - Public subnet
- `aws_internet_gateway` - Internet gateway
- `aws_security_group` - Security group for EC2
- `aws_key_pair` - SSH key pair
- `aws_instance` - EC2 instance with provisioners

## 👤 Author

**AbstractLK**

## 🔗 References

- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [Terraform VPC Module](https://registry.terraform.io/modules/terraform-aws-modules/vpc/aws/latest)
- [Amazon Linux 2023](https://aws.amazon.com/linux/amazon-linux-2023/)
