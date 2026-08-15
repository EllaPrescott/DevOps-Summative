# VPC creation

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  enable_dns_hostnames = true
  tags = {
    Name = "github-actions-vpc"
  }
}

# Public subnet creation
resource "aws_subnet" "public" {
  vpc_id = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-1a"
  map_public_ip_on_launch = true
  tags = {
    Name = "public-subnet"
  }
}

# Internet Gateway creation
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "github-actions-igw"
  }
}

# Route Table creation and association with the public subnet
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = "public-route-table"
  }
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}


# Security group configuration and incoming/outgoing rules for Flask app and SSH access

resource "aws_security_group" "flask" {
  name        = "flask-sg"
  description = "Allow Flask and SSH"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "Flask App"
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH Access"
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
}




# AMI selection for the Flask application instance using Amazon Linux 2023

data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }
}


# EC2 instance configuration for the Flask application, including user data for setup

resource "aws_instance" "flask" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.flask.id]
  associate_public_ip_address = true
  key_name              = "vockey"

  user_data = <<-EOF
#!/bin/bash
dnf update -y
dnf install python3 python3-pip git -y

mkdir -p /opt/application
chmod 777 /opt/application

echo "Server Ready" > /tmp/server-status.txt
EOF

  tags = {
    Name = "FlaskApp"
  }
}


