/* Hi! The configuration below will provision a basic
VPC with a subnet, a route table, a security group,
an internet gateway, an EC2 instance.

The tags of the resources are generated based on the
`resource_prefix` specified:
`resource_prefix-resource_type`
*/


terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region  = var.provider_region
  profile = var.aws_cli_profile
}

# Create a VPC
resource "aws_vpc" "nextcloud_vpc" {
  cidr_block = var.vpc_cidr

  tags = {
    Name = "${var.resource_prefix}vpc"
  }
}

# Subnet
resource "aws_subnet" "nextcloud_subnet" {
  vpc_id     = aws_vpc.nextcloud_vpc.id
  cidr_block = var.vpc_subnet_cidr

  tags = {
    Name = "${var.resource_prefix}subnet"
  }
}

# Route table
resource "aws_route_table" "nextcloud_rt" {
  vpc_id = aws_vpc.nextcloud_vpc.id

  route {
    cidr_block = var.enable_all_trafic_cidr
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "${var.resource_prefix}rt"
  }
}

resource "aws_main_route_table_association" "a" {
  vpc_id         = aws_vpc.nextcloud_vpc.id
  route_table_id = aws_route_table.nextcloud_rt.id
}

# Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.nextcloud_vpc.id

  tags = {
    Name = "${var.resource_prefix}igw"
  }
}

# Security group

resource "aws_security_group" "nextcloud_sg" {
  vpc_id = aws_vpc.nextcloud_vpc.id
  dynamic "ingress" {
    for_each = var.sg_ingress_ports

    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = [var.enable_all_trafic_cidr]
    }
  }

  dynamic "egress" {
    for_each = var.sg_egress_ports

    content {
      from_port   = egress.value
      to_port     = egress.value
      protocol    = "-1"
      cidr_blocks = [var.enable_all_trafic_cidr]
    }

  }
  tags = {
    Name = "${var.resource_prefix}sg"
  }
}

# EC2 instance
resource "aws_instance" "nextcloud" {
  ami           = var.ami
  instance_type = var.ec2_instance_type

  subnet_id                   = aws_subnet.nextcloud_subnet.id
  vpc_security_group_ids      = [aws_security_group.nextcloud_sg.id]
  associate_public_ip_address = true
  key_name                    = var.ec2_key_name

  root_block_device {
    volume_size = var.ec2_volume_size
    volume_type = var.ec2_volume_type
  }

  tags = {
    Name = "${var.resource_prefix}ec2"
  }
}

# Setup nextcloud once the EC2 instance and an A record was created
resource "null_resource" "setup_nextcloud" {
  depends_on = [aws_instance.nextcloud, aws_route53_record.nextcloud]

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file(var.private_key_path)
    host        = aws_instance.nextcloud.public_ip
  }

  provisioner "file" {
    content = templatefile("init.sh", {
      email           = var.email,
      domain_name     = var.nextcloud_domain_name,
      aws_cli_profile = var.aws_cli_profile
    })
    destination = "/tmp/init.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/init.sh",
      "bash /tmp/init.sh"
    ]
  }
}

# Route 53 A record pointing to the EC2 instance
resource "aws_route53_record" "nextcloud" {
  zone_id = var.route53_zone_id
  name    = var.nextcloud_domain_name
  type    = "A"
  ttl     = "300"
  records = [aws_instance.nextcloud.public_ip]
}
