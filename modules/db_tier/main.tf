#DB
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
  cidr_block = "10.0.3.0/24"
  availability_zone = "${var.region1}"
  map_public_ip_on_launch = false
  tags {
    Name = "${var.name}-db1-subnet"
  }
}

resource "aws_subnet" "db2" {
  vpc_id = "${var.vpc_id}"
  cidr_block = "10.0.4.0/24"
  availability_zone = "${var.region2}"
  map_public_ip_on_launch = false
  tags {
    Name = "${var.name}-db2-subnet"
  }
}

resource "aws_subnet" "db3" {
  vpc_id = "${var.vpc_id}"
  cidr_block = "10.0.5.0/24"
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

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["10.0.0.0/16"]
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
  target_group_arns = ["${aws_lb_target_group.db_TG.arn}"]
  tags {
    key = "Name"
    value = "Eng14db-${count.index}"
    propagate_at_launch = true
  }

}

resource "aws_lb" "db_lb" {
  name               = "${var.name}-lb-tf"
  internal           = false
  load_balancer_type = "network"
  subnets            = ["${aws_subnet.db1.id}"]
  enable_deletion_protection = false

  tags {
    Name = "${var.name}_lb"
  }
}

resource "aws_lb_target_group" "db_TG" {
  name     = "${var.name}-target-group"
  port     = "27017"
  protocol = "TCP"
  vpc_id   = "${var.vpc_id}"
}

resource "aws_lb_listener" "db_ln_l" {
  load_balancer_arn = "${aws_lb.db_lb.arn}"
  port              = "27017"
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.db_TG.arn}"
  }
}

resource "aws_route53_record" "www" {
  zone_id = "Z3CCIZELFLJ3SC"
  name    = "eng14db.spartaglobal.education"
  type    = "CNAME"
  ttl     = "300"
  records = ["${aws_lb.db_lb.dns_name}"]
}
