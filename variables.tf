variable "name" {
  default = "Eng14"
}

variable "app_ami" {
  default = "ami-08024609f6e6bc21b"
}

variable "db_ami" {
  default = "ami-0fc457fe0e90a6289"
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
