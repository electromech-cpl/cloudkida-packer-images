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
    Name        = "docker-compose-rocky-9-base-{{timestamp}}"
    Creator     = "cloudkida"
    Environment = "Prod"
  }
}

source "amazon-ebs" "docker-compose-rocky-9" {
  ami_name      = "docker-compose-rocky-9-base"
  instance_type = "t3a.medium"
  region        = "ap-south-1"
  source_ami_filter {
    filters = {
      name                = "Rocky-9-EC2-Base-9.1-20221123.0.x86_64-3f230a17-9877-4b16-aa5e-b1ff34ab206b"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["aws-marketplace"]
  }
  launch_block_device_mappings {
    volume_type           = "gp3"
    device_name           = "/dev/sda1"
    delete_on_termination = true
    volume_size           = 10
  }
  ssh_username = "rocky"
  tags         = local.tags

}

build {
  name    = "docker-compose-rocky-9-base"
  sources = ["source.amazon-ebs.docker-compose-rocky-9"]



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
    execute_command = "echo 'rocky' | {{ .Vars }} sudo -S -E bash '{{ .Path }}'"
    script          = "scripts/install_tools.sh"
  }

  provisioner "shell" {
    execute_command = "echo 'rocky' | {{ .Vars }} sudo -S -E bash '{{ .Path }}'"
    script          = "scripts/setup.sh"
  }

  provisioner "shell" {
    execute_command = "echo 'rocky' | {{ .Vars }} sudo -S -E bash '{{ .Path }}'"
    script          = "scripts/cleanup.sh"
  }
}