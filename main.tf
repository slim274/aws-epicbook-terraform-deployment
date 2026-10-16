provider "aws" {
  region = "us-east-1"
}

# ----------------------
# VPC
# ----------------------
resource "aws_vpc" "my_vpc" {
  cidr_block = "10.0.0.0/16"
  tags       = { Name = "EpicBook-VPC" }
}

# ----------------------
# Subnets
# ----------------------
resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1a"
  tags                    = { Name = "Public-Subnet" }
}

resource "aws_subnet" "private_subnet" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1a"
  tags              = { Name = "Private-Subnet" }
}

# ----------------------
# Internet Gateway
# ----------------------
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.my_vpc.id
  tags   = { Name = "EpicBook-IGW" }
}

# ----------------------
# Route Table
# ----------------------
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = { Name = "Public-Route-Table" }
}

resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_rt.id
}

# ----------------------
# Security Groups
# ----------------------
resource "aws_security_group" "ec2_sg" {
  name   = "EC2-SG"
  vpc_id = aws_vpc.my_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
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
}

resource "aws_security_group" "rds_sg" {
  name   = "RDS-SG"
  vpc_id = aws_vpc.my_vpc.id

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.ec2_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# ----------------------
# Key Pair (FIXED PATH)
# ----------------------
resource "aws_key_pair" "ec2_key" {
  key_name   = "epicbook-key"
  public_key = var.ssh_public_key
}

resource "aws_subnet" "private_subnet_2" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "us-east-1b"
  tags              = { Name = "Private-Subnet-2" }
}
# ----------------------
# RDS Subnet Group
# ----------------------
resource "aws_db_subnet_group" "rds_subnet_group" {
  name = "rds-subnet-group"
  subnet_ids = [
    aws_subnet.private_subnet.id,
    aws_subnet.private_subnet_2.id
  ]
}
# ----------------------
# RDS MySQL (FIXED)
# ----------------------
resource "aws_db_instance" "rds_mysql" {
  allocated_storage      = 20
  engine                 = "mysql"
  engine_version         = "8.0"
  instance_class         = "db.t3.micro"
  db_name                = "epicbookdb" # ✅ FIXED
  username               = "admin"
  password               = var.db_password
  db_subnet_group_name   = aws_db_subnet_group.rds_subnet_group.name
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  skip_final_snapshot    = true
  publicly_accessible    = false
}

# ----------------------
# EC2 Instance
# ----------------------
resource "aws_instance" "ec2" {
  ami                         = "ami-053b0d53c279acc90" # ✅ Updated Ubuntu 22.04
  instance_type               = "t3.micro"
  subnet_id                   = aws_subnet.public_subnet.id
  key_name                    = aws_key_pair.ec2_key.key_name
  vpc_security_group_ids      = [aws_security_group.ec2_sg.id]
  associate_public_ip_address = true

  depends_on = [aws_db_instance.rds_mysql]

  user_data = <<-EOF
              #!/bin/bash
              sudo apt update -y
              sudo apt install -y nodejs npm git nginx mysql-client

              git clone https://github.com/slim274/theepicbook.git /home/ubuntu/epicbook
              cd /home/ubuntu/epicbook
              npm install

              cat > .env <<EOL
              DB_HOST=${aws_db_instance.rds_mysql.address}
              DB_USER=admin
              DB_PASSWORD=CONFIGURE_SECURELY_AT_RUNTIME
              DB_NAME=epicbookdb
              EOL

              # Nginx config
              sudo bash -c 'cat > /etc/nginx/sites-available/epicbook <<NGCONF
              server {
                  listen 80;
                  location / {
                      proxy_pass http://localhost:3000;
                  }
              }
              NGCONF'

              sudo ln -s /etc/nginx/sites-available/epicbook /etc/nginx/sites-enabled/
              sudo systemctl restart nginx

              npm start &
              EOF

  tags = { Name = "EpicBook-EC2" }
}

# ----------------------
# Output
# ----------------------
output "ec2_public_ip" {
  value = aws_instance.ec2.public_ip
}