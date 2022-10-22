# Designate a cloud provider, region, and credentials
provider "aws" {
  profile = "default"
  region = "us-east-1"
}

# provision 4 AWS t2.micro EC2 instances named Udacity T2
resource "aws_instance" "Udacity_T2" {
  count = 4
  ami = "ami-0742b4e673072066f"
  instance_type = "t2.micro"
  subnet_id = var.public_subnet_id
  tags = {
    Name = "Udacity T2"
  }
}

# provision 2 m4.large EC2 instances named Udacity M4
resource "aws_instance" "Udacity_M4" {
  count = 2
  ami = "ami-09d3b3274b6c5d4aa"
  instance_type = "m4.large"
  subnet_id = var.public_subnet_id
  tags = {
    Name = "Udacity M4"
  }
}
