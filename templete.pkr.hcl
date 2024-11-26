packer {
  required_plugins {
    amazon = {
      source  = "github.com/hashicorp/amazon"
      version = "~> 1.3.2"
    }
  }
}

variable "aws_access_key" {
  default = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
}

variable "aws_secret_key" {
  default = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
}

variable "region" {
  default = "us-east-1"
}

variable "source_ami" {
  default = "ami-080e1f13689e07408"
}

variable "instance_type" {
  default = "t2.micro"
}

variable "vpc_id" {
  default = "vpc-0b0be2301718f3e5d"
}

variable "subnet_id" {
  default = "subnet-0c2037be3c3add238"
}
source "amazon-ebs" "custom_ami" {
  access_key    = var.aws_access_key
  secret_key    = var.aws_secret_key
  region        = var.region
  source_ami    = var.source_ami
  instance_type = var.instance_type
  ssh_username  = "ubuntu"
  ami_name      = "Srinivas-Jangam-Build-${replace(timestamp(), ":", "-")}"
  vpc_id        = var.vpc_id
  subnet_id     = var.subnet_id
  tags = {
    Name = "Srinivas-Jangam-Build-${replace(timestamp(), ":", "-")}"
  }
}


build {
  sources = ["source.amazon-ebs.custom_ami"]

  provisioner "shell" {
    inline = [
      "sleep 30",
      "sudo apt update -y",
      "sudo apt install nginx -y",
      "sudo apt install git -y",
      "sudo git clone https://github.com/srinivasreddyjangam/webhooktesting.git",
      "sudo rm -rf /var/www/html/index.nginx-debian.html",
      "sudo cp webhooktesting/index.html /var/www/html/index.nginx-debian.html",
      "sudo cp webhooktesting/style.css /var/www/html/style.css",
      "sudo cp webhooktesting/scorekeeper.js /var/www/html/scorekeeper.js",
      "sudo service nginx start",
      "sudo systemctl enable nginx",
      "curl https://get.docker.com | bash"
    ]
  }

  provisioner "file" {
    source      = "docker.service"
    destination = "/tmp/docker.service"
  }

  provisioner "shell" {
    inline = [
      "sudo cp /tmp/docker.service /lib/systemd/system/docker.service",
      "sudo usermod -a -G docker ubuntu",
      "sudo systemctl daemon-reload",
      "sudo service docker restart"
    ]
  }
}
