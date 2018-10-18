output "db_eip" {
  description = "The ip of the eip of db"
  value = "${aws_eip.eip.public_ip}"
}
