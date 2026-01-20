packer {
  required_plugins {
    amazon = {
      version = ">= 0.0.2"
      source  = "github.com/hashicorp/amazon"
    }
  }
}
locals {
  tags = {
    Name        = "rhcsa-rhel-9-base-{{timestamp}}"
    Creator     = "cloudkida"
    Environment = "Prod"
  }
}

source "amazon-ebs" "rhcsa-rhel-9" {
  ami_name      = "rhcsa-rhel-9-base"
  instance_type = "t3a.medium"
  region        = "ap-south-1"
  source_ami_filter {
    filters = {
      name                = "RHEL-9.2.0_HVM-20230503-x86_64-41-Hourly2-GP2"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["309956199498"]
  }
  launch_block_device_mappings {
    volume_type           = "gp3"
    device_name           = "/dev/sda1"
    delete_on_termination = true
    volume_size           = 10
  }
  launch_block_device_mappings {
    volume_type           = "gp3"
    device_name           = "/dev/sdb"
    delete_on_termination = true
    volume_size           = 1
  }
  launch_block_device_mappings {
    volume_type           = "gp3"
    device_name           = "/dev/sdc"
    delete_on_termination = true
    volume_size           = 1
  }
  ssh_username = "ec2-user"
  tags         = local.tags

}

build {
  name    = "rhcsa-rhel-9-base"
  sources = ["source.amazon-ebs.rhcsa-rhel-9"]



  provisioner "file" {
    destination = "/tmp/cloud.cfg"
    source      = "config/deafults.cfg"
  }

  provisioner "shell" {
    inline = ["sudo mv /tmp/cloud.cfg /etc/cloud/cloud.cfg.d/defaults.cfg"]
  }

  provisioner "file" {
    destination = "/tmp/motd.txt"
    source      = "scripts/motd.txt"
  }

  provisioner "shell" {
    inline = ["sudo mv /tmp/motd.txt /etc/motd"]
  }

  provisioner "shell" {
    execute_command = "echo 'ec2-user' | {{ .Vars }} sudo -S -E bash '{{ .Path }}'"
    script          = "scripts/install_tools.sh"
  }

  provisioner "shell" {
    execute_command = "echo 'ec2-user' | {{ .Vars }} sudo -S -E bash '{{ .Path }}'"
    script          = "scripts/setup.sh"
  }

  provisioner "shell" {
    execute_command = "echo 'ec2-user' | {{ .Vars }} sudo -S -E bash '{{ .Path }}'"
    script          = "scripts/cleanup.sh"
  }
}