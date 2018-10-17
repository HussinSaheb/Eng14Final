# security
resource "aws_security_group" "es_sg"  {
  name = "${var.name}"
  description = "${var.name} access"
  vpc_id = "${var.vpc_id}"

  ingress {
    from_port       = "1024"
    to_port         = "65535"
    protocol        = "tcp"
    security_groups = ["${var.ls_app_sg_id}"]
  }

  ingress {
    from_port       = "1024"
    to_port         = "65535"
    protocol        = "tcp"
    security_groups = ["${var.ls_db_sg_id}"]
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
