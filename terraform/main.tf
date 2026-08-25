# VPC creation

resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true

  tags = {
    Name = "student-vpc"
  }
}


# Public Subnet creation

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true

  tags = {
    Name = "public-subnet"
  }
}


# Internet Gateway creation

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "main-igw"
  }
}


# Route Table and Association

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


# Security Group for Flask App

resource "aws_security_group" "flask" {
  name        = "flask-app-sg"
  description = "Allow Flask and SSH"
  vpc_id      = aws_vpc.main.id


  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
}

  ingress {
    description = "SSH"
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
    Name = "flask-sg"
  }
}

#Key Pair creation for EC2 instance
resource "aws_key_pair" "vockey2" {
  key_name   = "vockey2"
  public_key = file("${path.module}/vockey.pub")
}

# Amazon Linux AMI
data "aws_ami" "amazon_linux" {
    most_recent = true
    owners = ["amazon"]

    filter {
        name = "name"
        values = ["al2023-ami-*-x86_64"]
    }
}

# EC2 instance creation for Flask App

resource "aws_instance" "flask" {
  ami                         = data.aws_ami.amazon_linux.id
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.public.id
  vpc_security_group_ids      = [aws_security_group.flask.id]
  associate_public_ip_address = true
  key_name                    = aws_key_pair.vockey2.key_name

  user_data = <<-EOF
  #!/bin/bash
  dnf update -y
  dnf install python3 python3-pip git nginx -y
  mkdir -p /opt/flaskapp
  chmod 777 /opt/flaskapp
  EOF

  tags = {
    Name = "FlaskApp"
  }
}

