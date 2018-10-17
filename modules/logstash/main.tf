# Security
resource "aws_security_group" "lg_app_sg"  {
  name = "LS_App_Group"
  description = "LS_App_Group access"
  vpc_id = "${var.vpc_id}"

  ingress {
    from_port       = "1024"
    to_port         = "65535"
    protocol        = "tcp"
    security_groups = ["${var.app_sg}"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  tags {
    Name = "LS_App_Group"
  }
}

resource "aws_security_group" "lg_db_sg"  {
  name = "LS_DB_Group"
  description = "LS_DB_Group access"
  vpc_id = "${var.vpc_id}"

  ingress {
    from_port       = "1024"
    to_port         = "65535"
    protocol        = "tcp"
    security_groups = ["${var.db_sg}"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  tags {
    Name = "LS_DB_Group"
  }
}

resource "aws_instance" "logstash-app" {
  ami = "${var.ami_id}"
  subnet_id = "${var.subnet_id}"
  vpc_security_group_ids = ["${aws_security_group.lg_app_sg.id}"]
  instance_type = "t2.micro"
  private_ip = "10.1.6.1"
  tags {
    Name = "Logstash-app-Test"
  }
}

resource "aws_instance" "logstash-db" {
  ami = "${var.ami_id}"
  subnet_id = "${var.subnet_id}"
  vpc_security_group_ids = ["${aws_security_group.lg_db_sg.id}"]
  instance_type = "t2.micro"
  private_ip = "10.1.6.2"
  tags {
    Name = "Logstash-db-Test"
  }
}
