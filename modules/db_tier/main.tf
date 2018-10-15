#setting the provider in this case AWS
provider "aws" {
  region ="eu-central-1"
}

# 1 - terraform
# Creating a VPC
resource "aws_vpc" "Eng14db" {
  cidr_block = "10.0.0.0/16"
  tags {
    Name = "${var.name}-vpc"
  }
}

#Module for the DB
module "db1" {
  source = "./modules/db_tier"
  vpc_id = "${aws_vpc.Eng14db.id}"
  name = "${var.name}"
  region = "${var.region1}"
  ami_id = "${var.db_ami_id}"
  app_sg = "${module.app.security_group_id}"
  app_subnet_cidr_block = "${module.app.subnet_cidr_block}"
}

module "db2" {
  source = "./modules/db_tier"
  vpc_id = "${aws_vpc.Eng14db.id}"
  name = "${var.name}"
  region = "${var.region2}"
  ami_id = "${var.db_ami_id}"
  app_sg = "${module.app.security_group_id}"
  app_subnet_cidr_block = "${module.app.subnet_cidr_block}"
}

module "db3" {
  source = "./modules/db_tier"
  vpc_id = "${aws_vpc.Eng14db.id}"
  name = "${var.name}"
  region = "${var.region3}"
  ami_id = "${var.db_ami_id}"
  app_sg = "${module.app.security_group_id}"
  app_subnet_cidr_block = "${module.app.subnet_cidr_block}"
}

#DB
#Database instance
resource "aws_instance" "TF-DB"{
  ami = "${var.ami_id}"
  subnet_id ="${aws_subnet.db.id}"
  vpc_security_group_ids = ["${var.db_sg}"]
  instance_type = "t2.micro"
  tags {
    Name = "${var.name}-TF-db"
  }
}

#Private route table for the DB
resource "aws_route_table" "db" {
  vpc_id = "${var.vpc_id}"

  tags {
    Name = "${var.name}-dbRT"
  }
}

#Private subnet for the DB
resource "aws_subnet" "db1" {
  vpc_id = "${var.vpc_id}"
  cidr_block = "10.0.2.0/24"
  availability_zone = "${var.region1}"
  map_public_ip_on_launch = false
  tags {
    Name = "${var.name}-db1-subnet"
  }
}

resource "aws_subnet" "db2" {
  vpc_id = "${var.vpc_id}"
  cidr_block = "10.0.3.0/24"
  availability_zone = "${var.region2}"
  map_public_ip_on_launch = false
  tags {
    Name = "${var.name}-db2-subnet"
  }
}

resource "aws_subnet" "db3" {
  vpc_id = "${var.vpc_id}"
  cidr_block = "10.0.4.0/24"
  availability_zone = "${var.region3}"
  map_public_ip_on_launch = false
  tags {
    Name = "${var.name}-db3-subnet"
  }
}

#Route table for the private DB
resource "aws_route_table_association" "db" {
  subnet_ids     = ["${aws_subnet.db1.id}","${aws_subnet.db2.id}","${aws_subnet.db3.id}"]
  route_table_id = "${aws_route_table.db.id}"
}

#Security group for the DB
resource "aws_security_group" "db" {
  name = "${var.name}-db"
  description = "db Security Group"
  vpc_id = "${var.vpc_id}"

  ingress {
    from_port = "27017"
    to_port = "27017"
    protocol = "tcp"
    security_groups = ["${var.app_sg}"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "${var.name}-db"
  }
}

#Nacl for the DB
resource "aws_network_acl" "db" {
  vpc_id = "${var.vpc_id}"

  ingress {
    protocol = "tcp"
    rule_no = 100
    action = "allow"
    cidr_block = "${var.app_subnet_cidr_block}"
    from_port = 27017
    to_port = 27017
  }

  #Empheral ports
  egress {
    protocol = "tcp"
    rule_no = 120
    action = "allow"
    cidr_block = "${var.app_subnet_cidr_block}"
    from_port = 1024
    to_port = 65535
  }

  ingress {
    protocol = "tcp"
    rule_no = 120
    action = "allow"
    cidr_block = "${var.app_subnet_cidr_block}"
    from_port = 1024
    to_port = 65535
  }
  subnet_ids = ["${aws_subnet.db1.id}","${aws_subnet.db2.id}","${aws_subnet.db3.id}"]

  tags {
    Name = "${var.name}-db-Nacl"
  }
}

#Creating a launch configuration
resource "aws_launch_configuration" "db" {
  name = "${var.name}-tf-launch_configuration"
  image_id = "${var.db_ami_id}"
  instance_type = "t2.micro"
  security_groups = ["${var.db_sg}}"]
  user_data = "${var.user_data}"
}

#Creating the Autoscaling group
resource "aws_autoscaling_group" "db" {
  name = "db-tf-asg"
  max_size = 3
  min_size = 0
  health_check_grace_period = 300
  health_check_type = "ELB"
  desired_capacity = 2
  force_delete = true
  launch_configuration = "${aws_launch_configuration.db.name}"
  vpc_zone_identifier = ["${aws_subnet.db1.id}","${aws_subnet.db2.id}","${aws_subnet.db3.id}"]
}
