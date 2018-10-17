# Security
resource "aws_security_group" "kb_app_sg"  {
  name = "${var.name}"
  description = "${var.name} access"
  vpc_id = "${var.vpc_id}"

  ingress {
    from_port       = "1024"
    to_port         = "65535"
    protocol        = "tcp"
    security_groups = ["10.1.6.3/32"]
  }

  ingress {
    from_port       = "80"
    to_port         = "80"
    protocol        = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
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

# Route 53
resource "aws_route53_record" "www" {
  zone_id = "${var.zone_id}"
  name    = "kibana14.spartaglobal.education"
  type    = "CNAME"
  ttl     = "300"
  records = ["${aws_instance.kibana.public_ip}"]
}

resource "aws_instance" "kibana" {
  ami = "${var.ami_id}"
  subnet_id = "${var.subnet_id}"
  vpc_security_group_ids = ["${aws_security_group.kb_app_sg.id}"]
  instance_type = "t2.micro"
  private_ip = "10.1.6.4"
  tags {
    Name = "Kibana-Test"
  }
}
