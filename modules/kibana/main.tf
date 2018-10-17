# Security
resource "aws_security_group" "kb_app_sg"  {
  name = "${var.name}"
  description = "${var.name} access"
  vpc_id = "${var.vpc_id}"

  ingress {
    from_port       = "1024"
    to_port         = "65535"
    protocol        = "tcp"
    security_groups = ["${var.es_sg}"]
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

resource "aws_instance" "kibana" {
  ami = "${var.ami_id}"
  subnet_id = "${var.subnet_id}"
  vpc_security_group_ids = "${aws_security_group.kb_app_sg.id}"
  instance_type = "t2.micro"
  tags {
    Name = "Kibana-Test"
  }
}
