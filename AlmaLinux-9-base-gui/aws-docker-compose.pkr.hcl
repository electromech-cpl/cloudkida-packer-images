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
    Name        = "AlmaLinux-9-base-gui-{{timestamp}}"
    Creator     = "cloudkida"
    Environment = "Prod"
  }
}

source "amazon-ebs" "AlmaLinux-9" {
  ami_name      = "AlmaLinux-9-base-gui"
  instance_type = "t3a.large"
  region        = "ap-south-1"
  source_ami_filter {
    filters = {
      name                = "AlmaLinux OS 9.1.20221117 x86_64-3c74c2ba-21a2-4dc1-a65d-fd0ee7d79900"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["679593333241"]
  }
  launch_block_device_mappings {
    volume_type           = "gp3"
    device_name           = "/dev/sda1"
    delete_on_termination = true
    volume_size           = 10
  }
  ssh_username = "ec2-user"
  tags         = local.tags

}

build {
  name    = "AlmaLinux-9-base-gui"
  sources = ["source.amazon-ebs.AlmaLinux-9"]



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