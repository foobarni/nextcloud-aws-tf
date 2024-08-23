variable "provider_region" {
  type    = string
  default = "us-east-1"
  description = "The region the resources will be provisioned in."
}

variable "aws_cli_profile" {
  type    = string
  default = "default"
  description = "The AWS CLI profile that is going to be used."
}

variable "resource_prefix" {
  type    = string
  default = "project-"
  description = "The prefix that will be prepended at the beginning of the resources' names."
}

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
  description = "The VPC's CIDR block."
}

variable "vpc_subnet_cidr" {
  type    = string
  default = "10.0.1.0/24"
  description = "The subnet's CIDR block."
}

variable "sg_ingress_ports" {
  type    = list(string)
  default = ["22", "80", "443"]
  description = "Security group inbound rules."
}

variable "sg_egress_ports" {
  type    = list(string)
  default = ["0"]
  description = "Security group outbound rules."
}

variable "enable_all_trafic_cidr" {
  default = "0.0.0.0/0"
  type    = string
  description = "Used to allow traffic from anywhere."
}

# Free tier eligible attributes:
variable "ami" {
  type    = string
  default = "ami-0e04bcbe83a83792e" # Ubuntu Server 24.04 LTS 64-bit (x86)
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
  default = "default-key"
  description = "Specify the key to connect via SSH to this instance."
}

variable "nextcloud_domain_name" {
  description = "The domain name to be used for the Nextcloud instance."
  type        = string
}

variable "email" {
  description = "The email address to use for SSL certificate generation."
  type        = string
}

variable "route53_zone_id" {
  description = "The ID of the existing Route 53 hosted zone."
  type        = string
}

variable "private_key_path" {
  description = "The path to the private key used to connect via SSH."
  type        = string
}
