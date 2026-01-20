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
    Name = "kali-2022-base-gui-{{timestamp}}"
    Creator = "cloudkida"
    Environment = "Prod"
  }
}

source "amazon-ebs" "kali-2022-gui" {
  ami_name      = "kali-2022-base-gui"
  instance_type = "t3a.small"
  region        = "ap-south-1"
  source_ami_filter {
    filters = {
      name                = "kali-rolling-amd64-2022.4.1-804fcc46-63fc-4eb6-85a1-50e66d6c7215"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["679593333241"]
  }
  launch_block_device_mappings {
      volume_type = "gp3"
      device_name = "/dev/xvda"
      delete_on_termination = true
      volume_size = 12
  }
  ssh_username = "kali"
  tags = local.tags

}

build {
  name    = "kali-2022-base-gui"
  sources = ["source.amazon-ebs.kali-2022-gui"]



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
    execute_command = "echo 'kali' | {{ .Vars }} sudo -S -E bash '{{ .Path }}'"
    script          = "scripts/install_tools.sh"
  }

  provisioner "shell" {
    execute_command = "echo 'kali' | {{ .Vars }} sudo -S -E bash '{{ .Path }}'"
    script          = "scripts/setup.sh"
  }

  provisioner "shell" {
    execute_command = "echo 'kali' | {{ .Vars }} sudo -S -E bash '{{ .Path }}'"
    script          = "scripts/cleanup.sh"
  }
  # provisioner "shell-local" {
  #   execute_command =  ["echo 'redhat' | {{ .Vars }} sudo -S -E bash '{{ .Path }}'"]
  #   script          = "testing/ssh-connect.sh"
  # }
}