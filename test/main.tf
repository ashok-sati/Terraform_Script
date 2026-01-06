```hcl
provider "aws" {
  region = "us-east-1" # Replace with your desired region
}

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "Main VPC"
  }
}

resource "aws_subnet" "public" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.1.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "Public Subnet"
  }
}

resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.2.0/24"

  tags = {
    Name = "Private Subnet"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "Main Internet Gateway"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "Public Route Table"
  }
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

resource "aws_security_group" "allow_http" {
  name        = "allow_http"
  description = "Allow HTTP inbound traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "public" {
  ami           = "ami-xxxxxxxx" # Replace with your desired AMI
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.allow_http.id]

  tags = {
    Name = "Public Instance"
  }
}

resource "aws_instance" "private" {
  ami           = "ami-xxxxxxxx" # Replace with your desired AMI
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.private.id

  tags = {
    Name = "Private Instance"
  }
}
```

This Terraform code creates the following resources:

- A VPC with the specified CIDR block
- A public subnet and a private subnet within the VPC
- An internet gateway attached to the VPC
- A public route table associated with the public subnet, allowing internet access
- A security group allowing HTTP inbound traffic from anywhere
- An EC2 instance in the public subnet with the specified AMI and instance type, associated with the security group
- An EC2 instance in the private subnet with the specified AMI and instance type

Note: You need to replace `ami-xxxxxxxx` with the desired AMI ID for your EC2 instances.