output "db_eip" {
  description = "The ip of the eip of db"
  value = "${aws_eip.nat_eip.public_ip}"
}
