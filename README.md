# CloudKida Packer Images

Multi-OS golden image builds using HashiCorp Packer for AWS AMIs. This repository contains ready-to-use Packer templates for building customized Amazon Machine Images (AMIs) across various operating systems and use cases.

## Table of Contents

- [Overview](#overview)
- [Prerequisites](#prerequisites)
  - [Installing Packer](#installing-packer)
  - [AWS CLI Setup](#aws-cli-setup)
  - [IAM Permissions](#iam-permissions)
- [Available Images](#available-images)
- [Repository Structure](#repository-structure)
- [Quick Start](#quick-start)
- [Customization Guide](#customization-guide)
- [Troubleshooting](#troubleshooting)
- [Contributing](#contributing)
- [License](#license)

---

## Overview

This repository provides Packer templates to build golden AMIs for:
- Base operating system images (Ubuntu, Debian, CentOS, AlmaLinux, Rocky Linux, Kali Linux)
- GUI-enabled desktop environments
- Container platforms (Docker Compose, Kubernetes, K3s, OpenShift)
- Security tools (Kali Linux, CALDERA, DefectDojo)
- Application stacks (WordPress, Ansible, Shuffle)

All images are configured with:
- Cloud-init defaults for consistent user management
- Custom MOTD (Message of the Day)
- Essential tools pre-installed
- Security hardening and cleanup scripts

---

## Prerequisites

### Installing Packer

#### macOS

```bash
# Using Homebrew
brew tap hashicorp/tap
brew install hashicorp/tap/packer

# Verify installation
packer --version
```

#### Ubuntu/Debian

```bash
# Add HashiCorp GPG key
wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg

# Add HashiCorp repository
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list

# Install Packer
sudo apt update && sudo apt install packer

# Verify installation
packer --version
```

#### RHEL/CentOS/Fedora

```bash
# Add HashiCorp repository
sudo yum install -y yum-utils
sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/RHEL/hashicorp.repo

# Install Packer
sudo yum install packer

# Verify installation
packer --version
```

#### Windows

```powershell
# Using Chocolatey
choco install packer

# Or using Scoop
scoop install packer

# Verify installation
packer --version
```

#### Manual Installation (All Platforms)

1. Download the appropriate package from [Packer Downloads](https://developer.hashicorp.com/packer/downloads)
2. Unzip the package
3. Add the binary to your system PATH

---

### AWS CLI Setup

#### Install AWS CLI

**macOS:**
```bash
curl "https://awscli.amazonaws.com/AWSCLIV2.pkg" -o "AWSCLIV2.pkg"
sudo installer -pkg AWSCLIV2.pkg -target /
```

**Linux:**
```bash
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
```

**Windows:**
```powershell
msiexec.exe /i https://awscli.amazonaws.com/AWSCLIV2.msi
```

#### Configure AWS CLI

```bash
aws configure
```

You will be prompted for:
- **AWS Access Key ID**: Your IAM user access key
- **AWS Secret Access Key**: Your IAM user secret key
- **Default region name**: e.g., `ap-south-1`, `us-east-1`, `eu-west-1`
- **Default output format**: `json` (recommended)

#### Using Environment Variables (Alternative)

```bash
export AWS_ACCESS_KEY_ID="your-access-key-id"
export AWS_SECRET_ACCESS_KEY="your-secret-access-key"
export AWS_DEFAULT_REGION="ap-south-1"
```

---

### IAM Permissions

Create an IAM user or role with the following permissions to build AMIs with Packer:

#### Minimum Required IAM Policy

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "PackerEC2Permissions",
      "Effect": "Allow",
      "Action": [
        "ec2:AttachVolume",
        "ec2:AuthorizeSecurityGroupIngress",
        "ec2:CopyImage",
        "ec2:CreateImage",
        "ec2:CreateKeypair",
        "ec2:CreateSecurityGroup",
        "ec2:CreateSnapshot",
        "ec2:CreateTags",
        "ec2:CreateVolume",
        "ec2:DeleteKeyPair",
        "ec2:DeleteSecurityGroup",
        "ec2:DeleteSnapshot",
        "ec2:DeleteVolume",
        "ec2:DeregisterImage",
        "ec2:DescribeImageAttribute",
        "ec2:DescribeImages",
        "ec2:DescribeInstances",
        "ec2:DescribeInstanceStatus",
        "ec2:DescribeRegions",
        "ec2:DescribeSecurityGroups",
        "ec2:DescribeSnapshots",
        "ec2:DescribeSubnets",
        "ec2:DescribeTags",
        "ec2:DescribeVolumes",
        "ec2:DetachVolume",
        "ec2:GetPasswordData",
        "ec2:ModifyImageAttribute",
        "ec2:ModifyInstanceAttribute",
        "ec2:ModifySnapshotAttribute",
        "ec2:RegisterImage",
        "ec2:RunInstances",
        "ec2:StopInstances",
        "ec2:TerminateInstances"
      ],
      "Resource": "*"
    }
  ]
}
```

#### Creating the IAM User

1. Go to AWS Console → IAM → Users → Add User
2. Enter username (e.g., `packer-builder`)
3. Select "Programmatic access"
4. Attach the policy above (create as custom policy or use `AmazonEC2FullAccess` for simplicity)
5. Save the Access Key ID and Secret Access Key

---

## Available Images

### Base Operating Systems

| Image | Description | Link |
|-------|-------------|------|
| [ubuntu-base](./ubuntu-base/) | Ubuntu base image | [View](./ubuntu-base/) |
| [ubuntu-22-04-base](./ubuntu-22-04-base/) | Ubuntu 22.04 LTS base | [View](./ubuntu-22-04-base/) |
| [ubuntu-22-04-GUI-base](./ubuntu-22-04-GUI-base/) | Ubuntu 22.04 with Desktop GUI | [View](./ubuntu-22-04-GUI-base/) |
| [debian-11-base](./debian-11-base/) | Debian 11 (Bullseye) base | [View](./debian-11-base/) |
| [debian-11-base-gui](./debian-11-base-gui/) | Debian 11 with Desktop GUI | [View](./debian-11-base-gui/) |
| [centos-8-base](./centos-8-base/) | CentOS Stream 8 base | [View](./centos-8-base/) |
| [centos-8-base-gui](./centos-8-base-gui/) | CentOS 8 with Desktop GUI | [View](./centos-8-base-gui/) |
| [AlmaLinux-9-base-gui](./AlmaLinux-9-base-gui/) | AlmaLinux 9 with Desktop GUI | [View](./AlmaLinux-9-base-gui/) |

### Container & Orchestration Platforms

| Image | Description | Link |
|-------|-------------|------|
| [docker-compose-ubuntu](./docker-compose-ubuntu/) | Ubuntu with Docker & Docker Compose | [View](./docker-compose-ubuntu/) |
| [docker-compose-rocky-9](./docker-compose-rocky-9/) | Rocky Linux 9 with Docker Compose | [View](./docker-compose-rocky-9/) |
| [ubuntu-22-04-base-Kubernetes](./ubuntu-22-04-base-Kubernetes/) | Ubuntu with Kubernetes | [View](./ubuntu-22-04-base-Kubernetes/) |
| [ubuntu-22-04-base-Kubernetes-v1.27](./ubuntu-22-04-base-Kubernetes-v1.27/) | Ubuntu with Kubernetes v1.27 | [View](./ubuntu-22-04-base-Kubernetes-v1.27/) |
| [ubuntu-22-04-base-K3s](./ubuntu-22-04-base-K3s/) | Ubuntu with K3s (Lightweight Kubernetes) | [View](./ubuntu-22-04-base-K3s/) |
| [OpenShift-Origin-3.11](./OpenShift-Origin-3.11/) | OpenShift Origin (OKD) 3.11 | [View](./OpenShift-Origin-3.11/) |
| [OpenShift-Origin-4.11](./OpenShift-Origin-4.11/) | OpenShift Origin (OKD) 4.11 | [View](./OpenShift-Origin-4.11/) |

### Security & Penetration Testing

| Image | Description | Link |
|-------|-------------|------|
| [kali-2022-base](./kali-2022-base/) | Kali Linux 2022 base | [View](./kali-2022-base/) |
| [kali-2022-base-gui](./kali-2022-base-gui/) | Kali Linux 2022 with GUI | [View](./kali-2022-base-gui/) |
| [kali-2023-base](./kali-2023-base/) | Kali Linux 2023 base | [View](./kali-2023-base/) |
| [kali-2023-base-gui](./kali-2023-base-gui/) | Kali Linux 2023 with GUI | [View](./kali-2023-base-gui/) |
| [caldera-ubuntu](./caldera-ubuntu/) | MITRE CALDERA on Ubuntu | [View](./caldera-ubuntu/) |
| [DefectDojo-ubuntu](./DefectDojo-ubuntu/) | DefectDojo Security Platform | [View](./DefectDojo-ubuntu/) |
| [InvinsenseXDR-4.9.2](./InvinsenseXDR-4.9.2/) | Invinsense XDR 4.9.2 | [View](./InvinsenseXDR-4.9.2/) |

### DevOps & Automation

| Image | Description | Link |
|-------|-------------|------|
| [Ansible-RHEL-9-Base](./Ansible-RHEL-9-Base/) | RHEL 9 with Ansible | [View](./Ansible-RHEL-9-Base/) |
| [Ansible-RHEL-9-GUI](./Ansible-RHEL-9-GUI/) | RHEL 9 with Ansible & GUI | [View](./Ansible-RHEL-9-GUI/) |
| [Shuffle-ubuntu](./Shuffle-ubuntu/) | Shuffle SOAR Platform | [View](./Shuffle-ubuntu/) |

### RHCSA Training

| Image | Description | Link |
|-------|-------------|------|
| [RHCSA-RHEL-9-Base](./RHCSA-RHEL-9-Base/) | RHEL 9 for RHCSA Training | [View](./RHCSA-RHEL-9-Base/) |
| [RHCSA-RHEL-9-GUI](./RHCSA-RHEL-9-GUI/) | RHEL 9 with GUI for RHCSA | [View](./RHCSA-RHEL-9-GUI/) |

### Application Stacks

| Image | Description | Link |
|-------|-------------|------|
| [WordPress-rocky-9](./WordPress-rocky-9/) | WordPress on Rocky Linux 9 | [View](./WordPress-rocky-9/) |

### Educational

| Image | Description | Link |
|-------|-------------|------|
| [Parul-University](./Parul-University/) | Custom images for Parul University | [View](./Parul-University/) |

---

## Repository Structure

Each image folder follows a consistent structure:

```
image-name/
├── aws-*.pkr.hcl      # Main Packer template file
├── config/
│   └── deafults.cfg   # Cloud-init configuration
├── scripts/
│   ├── install_tools.sh   # Package installation script
│   ├── setup.sh           # System configuration script
│   ├── cleanup.sh         # Cleanup and hardening script
│   └── motd.txt           # Message of the Day
└── testing/               # (Optional) Test scripts
    └── ssh-connect.sh
```


---

## Quick Start

### Step 1: Clone the Repository

```bash
git clone https://github.com/cloudkida/cloudkida-packer-images.git
cd cloudkida-packer-images
```

### Step 2: Choose an Image

Navigate to the desired image directory:

```bash
cd ubuntu-22-04-base
```

### Step 3: Initialize Packer

```bash
packer init .
```

This downloads the required Amazon plugin.

### Step 4: Validate the Template

```bash
packer validate .
```

### Step 5: Build the AMI

```bash
packer build .
```

Or specify the HCL file directly:

```bash
packer build aws-ubuntu.pkr.hcl
```

### Step 6: Find Your AMI

After a successful build, Packer outputs the AMI ID:

```
==> Builds finished. The artifacts of successful builds are:
--> ubuntu-22-04-base.amazon-ebs.ubuntu: AMIs were created:
ap-south-1: ami-0123456789abcdef0
```

---

## Customization Guide

### Changing the AWS Region

Edit the `.pkr.hcl` file and modify the `region` parameter:

```hcl
source "amazon-ebs" "ubuntu" {
  region = "us-east-1"  # Change to your preferred region
  # ...
}
```

### Changing Instance Type

Modify the `instance_type` for the build process:

```hcl
source "amazon-ebs" "ubuntu" {
  instance_type = "t3a.large"  # Use larger instance for faster builds
  # ...
}
```

### Changing Volume Size

Adjust the `volume_size` in the `launch_block_device_mappings`:

```hcl
launch_block_device_mappings {
  volume_type           = "gp3"
  device_name           = "/dev/sda1"
  delete_on_termination = true
  volume_size           = 50  # Size in GB
}
```

### Changing AMI Name

Modify the `ami_name` parameter:

```hcl
source "amazon-ebs" "ubuntu" {
  ami_name = "my-custom-ubuntu-image"
  # ...
}
```

### Customizing Tags

Edit the `locals` block to change AMI tags:

```hcl
locals {
  tags = {
    Name        = "my-custom-image-{{timestamp}}"
    Creator     = "your-name"
    Environment = "Development"
    Project     = "MyProject"
  }
}
```

### Installing Additional Packages

Edit `scripts/install_tools.sh` to add your packages:

```bash
#!/bin/bash -eux

# Install basic tools
apt update -y
apt install -y \
  net-tools \
  vim \
  wget \
  git \
  curl \
  htop \
  your-package-here

# Install Docker (example)
curl -fsSL https://get.docker.com | sh
```

### Changing Default User Password

Edit `config/deafults.cfg`:

```yaml
#cloud-config
system_info:
  default_user:
    name: ubuntu
    sudo: ["ALL=(ALL) NOPASSWD:ALL"]
    lock_passwd: false
    plain_text_passwd: 'your-secure-password'
```

### Adding Custom Scripts

1. Create your script in the `scripts/` folder
2. Add a provisioner in the `.pkr.hcl` file:

```hcl
build {
  # ... existing provisioners ...

  provisioner "shell" {
    execute_command = "echo 'ubuntu' | {{ .Vars }} sudo -S -E bash '{{ .Path }}'"
    script          = "scripts/my-custom-script.sh"
  }
}
```

### Uploading Custom Files

Use the `file` provisioner:

```hcl
provisioner "file" {
  source      = "config/my-config-file.conf"
  destination = "/tmp/my-config-file.conf"
}

provisioner "shell" {
  inline = ["sudo mv /tmp/my-config-file.conf /etc/my-app/config.conf"]
}
```

### Using Variables

Add variables for flexibility:

```hcl
variable "aws_region" {
  type    = string
  default = "ap-south-1"
}

variable "instance_type" {
  type    = string
  default = "t3a.micro"
}

source "amazon-ebs" "ubuntu" {
  region        = var.aws_region
  instance_type = var.instance_type
  # ...
}
```

Build with custom values:

```bash
packer build -var="aws_region=us-west-2" -var="instance_type=t3a.large" .
```

### Using a Variables File

Create `variables.pkrvars.hcl`:

```hcl
aws_region    = "us-west-2"
instance_type = "t3a.large"
volume_size   = 30
```

Build with the variables file:

```bash
packer build -var-file="variables.pkrvars.hcl" .
```

---

## Key Files Explained

### Packer Template (*.pkr.hcl)

The main configuration file containing:
- **packer block**: Required plugins
- **locals block**: Local variables and tags
- **source block**: AMI source configuration (base AMI, instance type, region)
- **build block**: Provisioners for customization

### config/deafults.cfg

Cloud-init configuration that sets:
- Default username
- Sudo permissions
- Default password

### scripts/install_tools.sh

Installs packages and software. Customize this to add your required tools.

### scripts/setup.sh

System configuration including:
- Sudoers configuration
- SSH settings
- System services

### scripts/cleanup.sh

Cleanup operations before AMI creation:
- Remove temporary files
- Clear bash history
- Disable unnecessary services

---

## Building Multiple Images

### Build All Images (Script Example)

```bash
#!/bin/bash

IMAGES=(
  "ubuntu-22-04-base"
  "debian-11-base"
  "centos-8-base"
)

for image in "${IMAGES[@]}"; do
  echo "Building $image..."
  cd "$image"
  packer init .
  packer build .
  cd ..
done
```

### Parallel Builds

```bash
packer build -parallel-builds=3 .
```

---

## Troubleshooting

### Common Issues

#### 1. "No valid credential sources found"

**Solution:** Configure AWS credentials:
```bash
aws configure
# Or set environment variables
export AWS_ACCESS_KEY_ID="your-key"
export AWS_SECRET_ACCESS_KEY="your-secret"
```

#### 2. "Error launching source instance: UnauthorizedOperation"

**Solution:** Ensure your IAM user has the required EC2 permissions (see [IAM Permissions](#iam-permissions)).

#### 3. "Timeout waiting for SSH"

**Solutions:**
- Check security group allows SSH (port 22)
- Verify the `ssh_username` matches the AMI's default user
- Increase timeout: `ssh_timeout = "30m"`

#### 4. "AMI name already exists"

**Solution:** Change the `ami_name` or delete the existing AMI:
```hcl
ami_name = "my-image-{{timestamp}}"  # Add timestamp for uniqueness
```

#### 5. "Source AMI not found"

**Solution:** Update the `source_ami_filter` with a valid AMI name for your region:
```bash
# Find available AMIs
aws ec2 describe-images --owners 099720109477 \
  --filters "Name=name,Values=ubuntu/images/hvm-ssd/ubuntu-jammy-22.04*" \
  --query 'Images[*].[Name,ImageId]' --output table
```

### Debug Mode

Enable detailed logging:

```bash
PACKER_LOG=1 packer build .
```

Save logs to file:

```bash
PACKER_LOG=1 PACKER_LOG_PATH="packer.log" packer build .
```

---

## SSH Usernames by OS

| Operating System | SSH Username |
|-----------------|--------------|
| Ubuntu | `ubuntu` |
| Debian | `admin` |
| CentOS | `centos` |
| RHEL | `ec2-user` |
| AlmaLinux | `ec2-user` |
| Rocky Linux | `rocky` |
| Amazon Linux | `ec2-user` |
| Kali Linux | `kali` |

---

## Contributing

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/new-image`
3. Make your changes
4. Test the build: `packer validate . && packer build .`
5. Commit your changes: `git commit -am 'Add new image'`
6. Push to the branch: `git push origin feature/new-image`
7. Submit a Pull Request

### Adding a New Image

1. Create a new folder with a descriptive name
2. Copy the structure from an existing similar image
3. Modify the `.pkr.hcl` file with appropriate settings
4. Update scripts as needed
5. Test the build
6. Update this README with the new image

---

## License

This project is licensed under the terms specified in the [LICENSE](./LICENSE) file.

---

## Support

For issues and questions:
- Open an issue on GitHub
- Contact: CloudKida Team

---

Made with ❤️ by [CloudKida](https://github.com/cloudkida)
