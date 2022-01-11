terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "3.71.0"
    }
  }
}

provider "aws" {
  region = "us-east-2"
  access_key = "AKIATD6KDN4QVIYX5DM7"
  secret_key = "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"
}

resource "aws_vpc" "experimental_terraform_vpc" {
  cidr_block       = "10.10.0.0/16"
  tags = {
    Name = "experimental_terraform"
  }
}

resource "aws_subnet" "experimental_terraform_vpc_subnet" {
  vpc_id     = aws_vpc.experimental_terraform_vpc.id
  cidr_block = "10.10.10.0/24"

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

resource "aws_route_table" "experimental_terraform_vpc_routetable" {
  vpc_id = aws_vpc.experimental_terraform_vpc.id

  route {
    cidr_block = "0.0.0.0/24"
    gateway_id = aws_internet_gateway.experimental_terraform_vpc_igw.id
  }

  tags = {
    Name = "experimental_terraform"
  }
}

resource "aws_security_group" "experimental_terraform_ec2_sg" {
  description = "Learn Terraform"
  vpc_id      = aws_vpc.experimental_terraform_vpc.id

  ingress {
    description      = "SSH"
    from_port        = 22
    to_port          = 22
    protocol         = "SSH"
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]

  }

  tags = {
    Name = "experimental_terraform"
  }
}

resource "aws_network_interface" "experimental_terraform_ec2_netinterface0" {
  subnet_id   = aws_subnet.experimental_terraform_vpc_subnet.id
  private_ips = ["10.10.10.1"]

  tags = {
    Name = "experimental_terraform_ec2_netinterface0"
  }
}

resource "aws_instance" "experimental_terraform_ec2" {
  ami           = "ami-0fb653ca2d3203ac"
  instance_type = "t2.micro"

  network_interface {
    network_interface_id = aws_network_interface.foo.id
    device_index         = 0
  }

  credit_specification {
    cpu_credits = "unlimited"
  }
}