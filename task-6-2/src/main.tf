terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "ap-northeast-1"
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "main"
    task = "6-2"
  }
}

resource "aws_subnet" "main_public" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.0.0/24"

  tags = {
    Name = "main-public"
    task = "6-2"
  }
}

resource "aws_internet_gateway" "main_igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "main"
    task = "6-2"
  }
}

resource "aws_route_table" "main_public_rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main_igw.id
  }

  tags = {
    Name = "main-public-rt"
    task = "6-2"
  }
}

resource "aws_route_table_association" "main_public_asso" {
  subnet_id      = aws_subnet.main_public.id
  route_table_id = aws_route_table.main_public_rt.id
}

resource "aws_security_group" "public_sg" {
  name        = "task-6-2-sg"
  description = "sg for ssh incoming"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 22
    to_port     = 22
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
    Name = "public-sg"
    task = "6-2"
  }
}

resource "aws_instance" "main" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.main_public.id
  key_name      = "task-6-2"
  vpc_security_group_ids = [
    aws_security_group.public_sg.id
  ]

  associate_public_ip_address = true

  tags = {
    Name = "main"
    task = "6-2"
  }
}

output "instance_public_ip" {
  value = aws_instance.main.public_ip
}

output "instance_id" {
  value = aws_instance.main.id
}

output "silly_outout" {
    value = "NOTHING BUT FOR MODIFICATION TRIGGER"
}
