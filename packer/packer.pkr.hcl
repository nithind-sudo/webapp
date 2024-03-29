packer {
  required_plugins {
    amazon = {
      version = ">= 1.1.1"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

variable "profile" {
  type    = string
  default = "dev"
}

variable "region" {
  type    = string
  default = "us-east-1"
}

variable "ssh_user" {
  type    = string
  default = "ec2-user"
}

variable "instance_type" {
  type    = string
  default = "t2.micro"
}

variable "account_to_share" {
  type    = string
  default = "397120193166"
}

variable "PORT" {
  type    = string
  default = "3000"
}

variable "DB_NAME" {
  type    = string
  default = "csye6225"
}

variable "USERNAME" {
  type    = string
  default = "ec2-user"
}

variable "PASSWORD" {
  type    = string
  default = "pass"
}

variable "DIALECT" {
  type    = string
  default = "postgres"
}

variable "HOST" {
  type    = string
  default = "127.0.0.1"
}

variable "NODE_ENV" {
  type    = string
  default = "development"
}

locals {
  timestamp = regex_replace(timestamp(), "[- TZ:]", "")
}

source "amazon-ebs" "webapp" {
  ami_name  = "webapp-ami-${local.timestamp}"
  ami_users = ["${var.account_to_share}"]

  source_ami_filter {
    filters = {
      name                = "amzn2-ami-hvm-2.*.1-x86_64-gp2"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["amazon"]
  }

  profile       = "${var.profile}"
  instance_type = "${var.instance_type}"
  region        = "${var.region}"
  ssh_username  = "${var.ssh_user}"

}


build {
  sources = [
    "source.amazon-ebs.webapp"
  ]

  provisioner "file" {
    source      = "./packer/config.json"
    destination = "/tmp/config.json"
  }

  provisioner "file" {
    source      = "./webapp.zip"
    destination = "/tmp/webapp.zip"
  }

  provisioner "shell" {
    script = "./packer/build.sh"
  }

}

