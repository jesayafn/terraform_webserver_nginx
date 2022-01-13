output "public_ip_ec2" {
  value = aws_instance.experimental_terraform.public_ip
}