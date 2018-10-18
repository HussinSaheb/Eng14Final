variable "vpc_id" {
  description = "the vpc id"
}

variable "db_ami_id" {
  description = "ami for the database"
}

variable "name" {
  default = "Mongod"
}

variable "region1" {
  default = "eu-west-3a"
}

variable "region2" {
  default = "eu-west-3b"
}

variable "region3" {
  default = "eu-west-3c"
}

variable "ig_id" {
  description = "internet gateway"
}

variable "app_sg" {
  description = "the app security group"
}

variable "app_subnet_cidr_block" {
  description = "the app subnet cidr block"
}
variable "user_data" {
  description = "the app subnet cidr block"
}
