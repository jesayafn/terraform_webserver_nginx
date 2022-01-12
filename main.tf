terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "3.71.0"
    }
  }
}

provider "aws" {
  region     = "us-east-2"
  access_key = var.aws_accesskey
  secret_key = var.aws_secretkey
}

resource "aws_vpc" "experimental_terraform_vpc" {
  cidr_block = "10.10.0.0/16"
  tags = {
    Name = "experimental_terraform"
  }
}

resource "aws_subnet" "experimental_terraform_vpc_subnet" {
  vpc_id                                      = aws_vpc.experimental_terraform_vpc.id
  cidr_block                                  = "10.10.10.0/24"
  map_public_ip_on_launch                     = true
  enable_resource_name_dns_a_record_on_launch = true
  tags = {
    Name = "experimental_terraform"
  }
}

resource "aws_internet_gateway" "experimental_terraform_vpc_igw" {
  vpc_id = aws_vpc.experimental_terraform_vpc.id

  tags = {
    Name = "experimental_terraform"
  }
}

resource "aws_route_table" "experimental_terraform_subnet_routetable" {
  vpc_id = aws_vpc.experimental_terraform_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.experimental_terraform_vpc_igw.id
  }

  tags = {
    Name = "experimental_terraform"
  }
}

resource "aws_route_table_association" "experimental_terraform_subnet_routetable_association" {
  subnet_id      = aws_subnet.experimental_terraform_vpc_subnet.id
  route_table_id = aws_route_table.experimental_terraform_subnet_routetable.id
}

resource "aws_security_group" "experimental_terraform_ec2_sg" {
  description = "Learn Terraform"
  vpc_id      = aws_vpc.experimental_terraform_vpc.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Ping"
    from_port   = 8
    to_port     = 0
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]

  }

  tags = {
    Name = "experimental_terraform"
  }
}

resource "aws_network_interface" "experimental_terraform_ec2_netinterface0" {
  subnet_id       = aws_subnet.experimental_terraform_vpc_subnet.id
  private_ips     = ["10.10.10.10"]
  security_groups = [aws_security_group.experimental_terraform_ec2_sg.id]
  tags = {
    Name = "experimental_terraform_ec2_netinterface0"
  }
}

resource "aws_instance" "experimental_terraform_ec2" {
  ami           = "ami-0fb653ca2d3203ac1"
  instance_type = "t2.micro"

  network_interface {
    network_interface_id = aws_network_interface.experimental_terraform_ec2_netinterface0.id
    device_index         = 0
  }

  
  user_data = "${file("nginx_install.sh")}"
  root_block_device {
    delete_on_termination = true
  }
}