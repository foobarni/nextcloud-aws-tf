aws_cli_profile = "default" # the profile you wish to use, also the admin user to your nextcloud
provider_region = "eu-central-1"

resource_prefix = "nextcloud-" # used as the prefix for the resources

vpc_cidr        = "10.0.0.0/16"
vpc_subnet_cidr = "10.0.1.0/24"

sg_ingress_ports = ["22", "80", "443"]
sg_egress_ports  = ["0"]

enable_all_trafic_cidr = "0.0.0.0/0"

ami               = "ami-07652eda1fbad7432" #ubuntu 22.04 LTS 64-bit (x86)
ec2_instance_type = "t2.micro"
ec2_volume_size   = 8
ec2_volume_type   = "gp2"
ec2_key_name      = "nextcloud-key" # the key to connect via ssh

nextcloud_domain_name = "your-cloud-domain.com"
email                 = "your_email_address@example.com"
route53_zone_id       = "" # the hosted zone where the A record will be created in
private_key_path      = "/path/to/the/key" # the path to the private key to connect via ssh
