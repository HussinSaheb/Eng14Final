#DB
resource "aws_instance" "Eng14DB1" {
  ami = "ami-01c2032f7a7ffa4e2"
  subnet_id = "${aws_subnet.db1.id}"
  security_groups = ["${aws_security_group.db.id}"]
  instance_type = "t2.micro"
  availability_zone = "${var.region1}"
  private_ip = "10.1.3.10"
  tags {
    Name = "Eng14DB1"
  }
}
resource "aws_instance" "Eng14DB2" {
  ami = "ami-01c2032f7a7ffa4e2"
  subnet_id = "${aws_subnet.db2.id}"
  security_groups = ["${aws_security_group.db.id}"]
  instance_type = "t2.micro"
  availability_zone = "${var.region2}"
  private_ip = "10.1.4.10"
  tags {
    Name = "Eng14DB2"
  }
}
resource "aws_instance" "Eng14DB3" {
  ami = "ami-01c2032f7a7ffa4e2"
  subnet_id = "${aws_subnet.db3.id}"
  security_groups = ["${aws_security_group.db.id}"]
  instance_type = "t2.micro"
  availability_zone = "${var.region3}"
  private_ip = "10.1.5.10"
  tags {
    Name = "Eng14DB3"
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
    from_port = "1025"
    to_port = "65535"
    protocol = "tcp"
    cidr_blocks = ["10.1.0.0/16"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["10.1.0.0/16"]
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
