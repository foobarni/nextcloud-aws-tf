variable "provider_region" {
  type    = string
  default = "us-east-1"
}

variable "aws_cli_profile" {
  type    = string
  default = "workshop"
}

variable "resource_prefix" {
  type    = string
  default = "workshop-"
}

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "vpc_subnet_cidr" {
  type    = string
  default = "10.0.1.0/24"
}

variable "sg_ingress_ports" {
  type    = list(string)
  default = ["22", "80", "443"]
}

variable "sg_egress_ports" {
  type    = list(string)
  default = ["0"]
}

variable "enable_all_trafic_cidr" {
  default = "0.0.0.0/0"
  type    = string
}

variable "ami" {
  type    = string
  default = "ami-04a81a99f5ec58529" #ubuntu 64-bit (x86)
}

variable "ec2_instance_type" {
  type    = string
  default = "t2.micro"
}

variable "ec2_volume_size" {
  type    = number
  default = "8"
}

variable "ec2_volume_type" {
  type    = string
  default = "gp2"
}

variable "ec2_key_name" {
  type    = string
  default = "barnabas-darai-workshop-key"
}

variable "nextcloud_domain_name" {
  description = "The domain name for the Nextcloud instance"
  type        = string
}

variable "email" {
  description = "The email address for SSL certificate"
  type        = string
}

variable "route53_zone_id" {
  description = "The ID of the existing Route 53 hosted zone"
  type        = string
}

variable "private_key_path" {
  description = "The ID of the existing Route 53 hosted zone"
  type        = string
}
