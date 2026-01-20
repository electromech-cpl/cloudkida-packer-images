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
    Name        = "openShift-origin-4-11-{{timestamp}}"
    Creator     = "cloudkida"
    Environment = "Prod"
  }
}

source "amazon-ebs" "openShift-origin" {
  ami_name      = "openShift-origin-4-11"
  instance_type = "t3a.large"
  region        = "ap-south-1"
  source_ami_filter {
    filters = {
      #name                = "ubuntu/images/*ubuntu-jammy-22.04-amd64-server-*"
      name                = "CentOS-Stream-ec2-8-20220919.1.x86_64-a5911e94-1971-4697-9bc5-02904340f1df"
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
    volume_size           = 15
  }
  ssh_username = "ec2-user"
  tags         = local.tags

}

build {
  name    = "openShift-origin-4-11"
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