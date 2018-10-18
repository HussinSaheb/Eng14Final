<<<<<<< HEAD
output "db_eip" {
  description = "The ip of the eip of db"
  value = "${aws_eip.eip.public_ip}"
=======
output "security_group_id" {
  description = "The id of the security group"
  value = "${aws_security_group.db.id}"
}

output "db_host1" {
  description = "Assign the IP for db_host"
  value = "${aws_instance.Eng14DB1.private_ip}"
}
output "db_host2" {
  description = "Assign the IP for db_host"
  value = "${aws_instance.Eng14DB2.private_ip}"
}
output "db_host3" {
  description = "Assign the IP for db_host"
  value = "${aws_instance.Eng14DB3.private_ip}"
>>>>>>> 3a50bdfde4f4555c2638bafec9478bf6509260cf
}
