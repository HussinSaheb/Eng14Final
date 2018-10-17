# APP

# create a subnet
resource "aws_subnet" "app1" {
  vpc_id = "${var.vpc_id}"
  cidr_block = "10.1.0.0/24"
  map_public_ip_on_launch = true
  availability_zone = "eu-west-1a"
  tags {
    Name = "${var.name}"
  }
}
resource "aws_subnet" "app2" {
  vpc_id = "${var.vpc_id}"
  cidr_block = "10.1.1.0/24"
  map_public_ip_on_launch = true
  availability_zone = "eu-west-1b"
  tags {
    Name = "${var.name}"
  }
}
resource "aws_subnet" "app3" {
  vpc_id = "${var.vpc_id}"
  cidr_block = "10.1.2.0/24"
  map_public_ip_on_launch = true
  availability_zone = "eu-west-1c"
  tags {
    Name = "${var.name}"
  }
}

# security
resource "aws_security_group" "app"  {
  name = "${var.name}"
  description = "${var.name} access"
  vpc_id = "${var.vpc_id}"

  ingress {
    from_port       = "80"
    to_port         = "80"
    protocol        = "tcp"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  tags {
    Name = "${var.name}"
  }
}

resource "aws_network_acl" "app" {
  vpc_id = "${var.vpc_id}"

  egress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 80
    to_port    = 80
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 80
    to_port    = 80
  }

  # EPHEMERAL PORTS

  egress {
    protocol   = "tcp"
    rule_no    = 120
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 1024
    to_port    = 65535
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 120
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 1024
    to_port    = 65535
  }

  subnet_ids   = ["${aws_subnet.app1.id}", "${aws_subnet.app2.id}", "${aws_subnet.app3.id}"]

  tags {
    Name = "${var.name}"
  }
}

# public route table
resource "aws_route_table" "app" {
  vpc_id = "${var.vpc_id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${var.ig_id}"
  }

  tags {
    Name = "${var.name}-public"
  }
}

resource "aws_route_table_association" "app1" {
  subnet_id      = "${aws_subnet.app1.id}"
  route_table_id = "${aws_route_table.app.id}"
}

resource "aws_route_table_association" "app2" {
  subnet_id      = "${aws_subnet.app2.id}"
  route_table_id = "${aws_route_table.app.id}"
}

resource "aws_route_table_association" "app3" {
  subnet_id      = "${aws_subnet.app3.id}"
  route_table_id = "${aws_route_table.app.id}"
}

# Route 53
resource "aws_route53_record" "www" {
  zone_id = "${var.zone_id}"
  name    = "eng14.spartaglobal.education"
  type    = "CNAME"
  ttl     = "300"
  records = ["${aws_lb.Eng14LB.dns_name}"]
}


resource "aws_lb" "Eng14LB" {
  name               = "${var.name}-app-elb"
  internal           = false
  load_balancer_type = "network"
  subnets = ["${aws_subnet.app1.id}", "${aws_subnet.app2.id}", "${aws_subnet.app3.id}"]
  enable_deletion_protection = false

  tags {
    Name = "Eng14LB"
  }
}

resource "aws_lb_target_group" "Eng14AppTG" {
  name     = "Eng14AppTG"
  port     = 80
  protocol = "TCP"
  vpc_id   = "${var.vpc_id}"
}

resource "aws_lb_listener" "Eng14AppL" {
  load_balancer_arn = "${aws_lb.Eng14LB.arn}"
  port = 80
  protocol = "TCP"

  default_action {
    type = "forward"
    target_group_arn = "${aws_lb_target_group.Eng14AppTG.arn}"
  }
}

resource "aws_launch_configuration" "Eng14LaunchConfig" {
  name_prefix   = "${var.name}-app"
  image_id      = "${var.ami_id}"
  instance_type = "t2.micro"
  user_data = "${var.user_data}"
  security_groups = ["${aws_security_group.app.id}"]

}

resource "aws_autoscaling_group" "Eng14AppAutoScaling" {
  name = "Eng14AppAutoScaling"
  vpc_zone_identifier = ["${aws_subnet.app1.id}", "${aws_subnet.app2.id}", "${aws_subnet.app3.id}"]
  desired_capacity = 3
  max_size = 3
  min_size = 3
  launch_configuration = "${aws_launch_configuration.Eng14LaunchConfig.name}"
  target_group_arns = ["${aws_lb_target_group.Eng14AppTG.arn}"]
  tags {
    key = "Name"
    value = "Eng14app"
    propagate_at_launch = true
  }
}
