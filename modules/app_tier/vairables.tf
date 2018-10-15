variable "vpc_id" {
  description = "the vpc to launch the resource to"
}



variable "user_data" {
  description = "the user data to provision the instance"
}

variable "ig_id" {
  description = "The internet gateway to attach to route table"
}


variable "ami_id" {
  description = "The app ami"
}

variable "availability_zone" {
  default = "eu-west-1a, eu-west-1b, eu-west-1c"
}
variable "name" {
  default="Eng14app"
  description = "The name of the user"
}


variable "cidr_block" {
  default="10.7.0.0/16"
}

variable "internal" {
  description = "should the ELB be internal or external"
  default = "false"
}

variable "zone_id" {
  description = "Sparta Education Zone ID"
  default="Z3CCIZELFLJ3SC"
}
