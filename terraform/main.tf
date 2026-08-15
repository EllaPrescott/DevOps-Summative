# Security group configuration and incoming/outgoing rules for Flask app and SSH access

resource "aws_security_group" "flask" {
  name        = "flask-sg"
  description = "Allow Flask and SSH"
  vpc_id      = data.aws_vpc.default.id

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


# Establishing AWS Academy default VPC and subnet for the Flask application instance

data "aws_vpc" "default" {
  default = true
}

data "aws_subnet" "default" {
  filter {
    name   = "default-for-az"
    values = ["true"]
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
  subnet_id              = data.aws_subnet.default.id
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


