#DB
resource "aws_instance" "Eng14Bastion" {
  ami = "ami-01c2032f7a7ffa4e2"
  subnet_id = "${aws_subnet.natdb1.id}"
  security_groups = ["${aws_security_group.bastion.id}"]
  instance_type = "t2.micro"
  availability_zone = "eu-west-1a"
  tags {
    Name = "Eng14Bastion"
  }
}

#Private route table for the DB
resource "aws_route_table" "db" {
  vpc_id = "${var.vpc_id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_nat_gateway.db_nat.id}"
  }

  tags {
    Name = "${var.name}-dbRT"
  }
}
# NAT route table
resource "aws_route_table" "nat_gateway" {
  vpc_id = "${var.vpc_id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${var.ig_id}"
  }

  tags {
    Name = "${var.name}-nat_gateway"
  }
}

#Private subnet for the DB
resource "aws_subnet" "db1" {
  vpc_id = "${var.vpc_id}"
  cidr_block = "10.1.3.0/24"
  availability_zone = "${var.region1}"
  map_public_ip_on_launch = false
  tags {
    Name = "${var.name}-db1-subnet"
  }
}

resource "aws_subnet" "db2" {
  vpc_id = "${var.vpc_id}"
  cidr_block = "10.1.4.0/24"
  availability_zone = "${var.region2}"
  map_public_ip_on_launch = false
  tags {
    Name = "${var.name}-db2-subnet"
  }
}

resource "aws_subnet" "db3" {
  vpc_id = "${var.vpc_id}"
  cidr_block = "10.1.5.0/24"
  availability_zone = "${var.region3}"
  map_public_ip_on_launch = false
  tags {
    Name = "${var.name}-db3-subnet"
  }
}

resource "aws_subnet" "natdb1" {
  vpc_id = "${var.vpc_id}"
  cidr_block= "10.1.7.0/24"
  availability_zone = "${var.region1}"
  map_public_ip_on_launch = true
  tags {
    Name = "${var.name}-natdb1-pubsubnet"
  }
}
resource "aws_subnet" "natdb2" {
  vpc_id = "${var.vpc_id}"
  cidr_block= "10.1.8.0/24"
  availability_zone = "${var.region2}"
  map_public_ip_on_launch = true
  tags {
    Name = "${var.name}-natdb2-pubsubnet"
  }
}
resource "aws_subnet" "natdb3" {
  vpc_id = "${var.vpc_id}"
  cidr_block= "10.1.9.0/24"
  availability_zone = "${var.region3}"
  map_public_ip_on_launch = true
  tags {
    Name = "${var.name}-natdb3-pubsubnet"
  }
}

#Route table for the private DB
resource "aws_route_table_association" "db1" {
  subnet_id     = "${aws_subnet.db1.id}"
  route_table_id = "${aws_route_table.db.id}"
}
resource "aws_route_table_association" "db2" {
  subnet_id     = "${aws_subnet.db2.id}"
  route_table_id = "${aws_route_table.db.id}"
}
resource "aws_route_table_association" "db3" {
  subnet_id     = "${aws_subnet.db3.id}"
  route_table_id = "${aws_route_table.db.id}"
}

# NAT route associations
resource "aws_route_table_association" "natdb1" {
  subnet_id     = "${aws_subnet.natdb1.id}"
  route_table_id = "${aws_route_table.nat_gateway.id}"
}
resource "aws_route_table_association" "natdb2" {
  subnet_id     = "${aws_subnet.natdb2.id}"
  route_table_id = "${aws_route_table.nat_gateway.id}"
}
resource "aws_route_table_association" "natdb3" {
  subnet_id     = "${aws_subnet.natdb3.id}"
  route_table_id = "${aws_route_table.nat_gateway.id}"
}
resource "aws_security_group" "bastion" {
  name = "${var.name}-bastion"
  vpc_id = "${var.vpc_id}"

  ingress {
    from_port = 0
    to_port = 0
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

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

  ingress {
<<<<<<< HEAD
    from_port = "1025"
    to_port = "65535"
=======
    from_port = "27017"
    to_port = "27017"
>>>>>>> d7072e48e2906d0c0369d54fc00ce5906d4f93ea
    protocol = "tcp"
    cidr_blocks = ["10.1.0.0/16"]
  }

<<<<<<< HEAD
=======

>>>>>>> d7072e48e2906d0c0369d54fc00ce5906d4f93ea
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
<<<<<<< HEAD
    cidr_blocks = ["10.1.0.0/16"]
=======
    cidr_blocks = ["0.0.0.0/0"]
>>>>>>> d7072e48e2906d0c0369d54fc00ce5906d4f93ea
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
    cidr_block = "10.1.0.0/16"
    from_port = 27017
    to_port = 27017
  }

  ingress {
    protocol = "tcp"
    rule_no = 110
    action = "allow"
    cidr_block = "10.1.0.0/16"
    from_port = 1024
    to_port = 65535
  }

  #Empheral ports
  egress {
    protocol = "tcp"
    rule_no = 120
    action = "allow"
    cidr_block = "10.1.0.0/16"
    from_port = 1024
    to_port = 65535
  }

  subnet_ids = ["${aws_subnet.db1.id}","${aws_subnet.db2.id}","${aws_subnet.db3.id}"]

  tags {
    Name = "${var.name}-db-Nacl"
  }
}
# NACL for NAT Public subnet
resource "aws_network_acl" "pub_db" {
  vpc_id = "${var.vpc_id}"

  ingress {
    protocol = "tcp"
    rule_no = 100
    action = "allow"
    cidr_block = "0.0.0.0/0"
    from_port = 1024
    to_port = 65535
  }

  #Empheral ports
  egress {
    protocol = "tcp"
    rule_no = 120
    action = "allow"
    cidr_block = "0.0.0.0/0"
    from_port = 1024
    to_port = 65535
  }
  subnet_ids = ["${aws_subnet.natdb1.id}","${aws_subnet.natdb2.id}","${aws_subnet.natdb3.id}"]

  tags {
    Name = "${var.name}-db-Nacl-BAS"
  }

}

#Creating a launch configuration
resource "aws_launch_configuration" "db" {
  name = "${var.name}-tf-launch_configuration"
  image_id = "${var.db_ami_id}"
  instance_type = "t2.micro"
  security_groups = ["${aws_security_group.db.id}"]
  # user_data = "${var.user_data}"
}

#Creating the Autoscaling group
resource "aws_autoscaling_group" "db" {
  name = "db-tf-asg"
  max_size = 3
  min_size = 0
  health_check_grace_period = 300
  health_check_type = "ELB"
  desired_capacity = 3
  force_delete = true
  launch_configuration = "${aws_launch_configuration.db.name}"
  vpc_zone_identifier = ["${aws_subnet.db1.id}","${aws_subnet.db2.id}","${aws_subnet.db3.id}"]
}

# NAT & elastic_ip
resource "aws_eip" "nat_eip" {
  vpc = true
  instance = "${aws_instance.Eng14Bastion.id}"
}

resource "aws_nat_gateway" "db_nat" {
  allocation_id = "${aws_eip.nat_eip.id}"
  subnet_id     = "${aws_subnet.natdb1.id}"

  tags {
    Name = "NAT DB-Public"
  }
}
