# security
resource "aws_security_group" "es_sg"  {
  name = "${var.name}"
  description = "${var.name} access"
  vpc_id = "${var.vpc_id}"

  ingress {
    from_port       = "1024"
    to_port         = "65535"
    protocol        = "tcp"
    cidr_blocks = ["10.1.6.7/32"]
  }

  ingress {
    from_port       = "1024"
    to_port         = "65535"
    protocol        = "tcp"
    cidr_blocks     = ["10.1.6.4/32"]
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

resource "aws_instance" "elasticsearch" {
  ami = "${var.ami_id}"
  subnet_id = "${var.subnet_id}"
  vpc_security_group_ids = ["${aws_security_group.es_sg.id}"]
  instance_type = "t2.micro"
  private_ip = "10.1.6.5"
  tags {
    Name = "Elasticsearch-Test"
  }
}
