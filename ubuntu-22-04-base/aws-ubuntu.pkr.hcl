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
    Name = "ubuntu-22-04-base-{{timestamp}}"
    Creator = "cloudkida"
    Environment = "Prod"
  }
}

source "amazon-ebs" "ubuntu" {
  ami_name      = "ubuntu-22-04-base"
  instance_type = "t3a.micro"
  region        = "ap-south-1"
  source_ami_filter {
    filters = {
      #name                = "ubuntu/images/*ubuntu-jammy-22.04-amd64-server-*"
      name                = "ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-20230115"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["099720109477"]
  }
  launch_block_device_mappings {
      volume_type = "gp3"
      device_name = "/dev/sda1"
      delete_on_termination = true
      volume_size = 8
  }
  ssh_username = "ubuntu"
  tags = local.tags

}

build {
  name    = "ubuntu-22-04-base"
  sources = ["source.amazon-ebs.ubuntu"]



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
    execute_command = "echo 'ubuntu' | {{ .Vars }} sudo -S -E bash '{{ .Path }}'"
    script          = "scripts/install_tools.sh"
  }

  provisioner "shell" {
    execute_command = "echo 'ubuntu' | {{ .Vars }} sudo -S -E bash '{{ .Path }}'"
    script          = "scripts/setup.sh"
  }

  provisioner "shell" {
    execute_command = "echo 'ubuntu' | {{ .Vars }} sudo -S -E bash '{{ .Path }}'"
    script          = "scripts/cleanup.sh"
  }
  # provisioner "shell-local" {
  #   execute_command =  ["echo 'redhat' | {{ .Vars }} sudo -S -E bash '{{ .Path }}'"]
  #   script          = "testing/ssh-connect.sh"
  # }
}