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
    Name        = "openShift-origin-base-{{timestamp}}"
    Creator     = "cloudkida"
    Environment = "Prod"
  }
}

source "amazon-ebs" "openShift-origin" {
  ami_name      = "openShift-origin-base"
  instance_type = "t3a.large"
  region        = "ap-south-1"
  source_ami_filter {
    filters = {
      #name                = "ubuntu/images/*ubuntu-jammy-22.04-amd64-server-*"
      name                = "amzn2-ami-kernel-5.10-hvm-2.0.20230119.1-x86_64-gp2"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["137112412989"]
  }
  launch_block_device_mappings {
    volume_type           = "gp3"
    device_name           = "/dev/xvda"
    delete_on_termination = true
    volume_size           = 15
  }
  ssh_username = "ec2-user"
  tags         = local.tags

}

build {
  name    = "openShift-origin-base"
  sources = ["source.amazon-ebs.openShift-origin"]



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
  # provisioner "shell-local" {
  #   execute_command =  ["echo 'redhat' | {{ .Vars }} sudo -S -E bash '{{ .Path }}'"]
  #   script          = "testing/ssh-connect.sh"
  # }
}