<<<<<<< HEAD
output "security_group_id" {
  description = "The id of the security group"
  value = "${aws_security_group.db.id}"
=======
output "db_eip" {
  description = "The ip of the eip of db"
  value = "${aws_eip.nat_eip.public_ip}"
>>>>>>> d7072e48e2906d0c0369d54fc00ce5906d4f93ea
}
