variable "db_ami_id" {
  default = "ami-0af33b09923244b93"
}

variable "name" {
  default = "Mongod"
}



variable "region1" {
  default = "eu-central-1a"
}

variable "region2" {
  default = "eu-central-1b"
}

variable "region3" {
  default = "eu-central-1c"
}

variable "user_data" {
  description = "the user data for db"
}

variable "app_sg" {
  description = "the app security group"
}

variable "app_subnet_cidr_block" {
  description = "the app subnet cidr block"
}
