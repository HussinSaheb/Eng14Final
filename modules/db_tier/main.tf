
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
    from_port = "27017"
    to_port = "27017"
    protocol = "tcp"
    cidr_blocks = ["10.1.0.0/16"]
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


#Creating a launch configuration
resource "aws_launch_configuration" "db" {
  name = "${var.name}-tf-launch_configuration"
  image_id = "${var.db_ami_id}"
  instance_type = "t2.micro"
  security_groups = ["${aws_security_group.db.id}"]
  iam_instance_profile = "${aws_iam_instance_profile.ec2_profile.name}"
  # user_data = "${var.user_data}"
  provisioner "local-exec" {
    command = "aws ec2 associate-address --instance-id $(curl http://169.254.169.254/latest/meta-data/instance-id) --allocation-id ${aws_eip.eip.id}"
  }
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
resource "aws_eip" "eip" {
  vpc = true
}


resource "aws_iam_role" "ec2" {
  name = "ec2"
  assume_role_policy = <<EOF
{
      "Version": "2012-10-17",
      "Statement": [
        {
          "Action": [
            "ec2:DescribeAddress",
            "ec2:AllocateAddress",
            "ec2:DescribeInstance",
            "ec2:AssociateAddress"
          ],
          "Principal": {
            "Service": "ec2.amazonaws.com"
          },
          "Effect": "Allow"
        }
      ]
  }
EOF
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "ec2_profile"
  role = "${aws_iam_role.ec2.name}"
}
