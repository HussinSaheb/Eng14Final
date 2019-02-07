output "sg_app_id" {
  value = "${aws_security_group.lg_app_sg.id }"
}

output "sg_db_id" {
  value = "${aws_security_group.lg_db_sg.id }"
}
