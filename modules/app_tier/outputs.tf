output subnet_app1_id {
  description = "The id of the subnet"
  value = "${aws_subnet.app1.id}"
}

output subnet_app2_id {
  description = "The id of the subnet"
  value = "${aws_subnet.app2.id}"
}

output subnet_app3_id {
  description = "The id of the subnet"
  value = "${aws_subnet.app3.id}"
}

output subnet_cidr_block {
  description = "The cidr block of the subnet"
  value = "${aws_subnet.app1.cidr_block}"
}

output security_group_id {
  description = "The id of the security group"
  value = "${aws_security_group.app.id}"
}
