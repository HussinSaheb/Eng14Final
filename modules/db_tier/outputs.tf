output "db_eip" {
  description = "The ip of the eip of db"
  value = "${aws_lb.db_lb.dns_name}"
}
