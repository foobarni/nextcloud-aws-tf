output "nextcloud_vpc_id" {
  value = aws_vpc.nextcloud_vpc.id
}

output "nextcloud_rt_id" {
  value = aws_route_table.nextcloud_rt.id
}

output "instance_id" {
  value = aws_instance.nextcloud.id
}

output "public_ip" {
  value = aws_instance.nextcloud.public_ip
}
