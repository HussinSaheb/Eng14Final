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
  default = "eu-west-1a"
}

variable "region2" {
  default = "eu-west-1b"
}

variable "region3" {
  default = "eu-west-1c"
}

variable "ig_id" {
  description = "internet gateway"
}

# variable "user_data" {
#   description = "the user data for db"
# }

variable "app_sg" {
  description = "the app security group"
}

variable "app_subnet_cidr_block" {
  description = "the app subnet cidr block"
}
