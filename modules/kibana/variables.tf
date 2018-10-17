variable "vpc_id" {}

variable "ig_id" {}

variable "subnet_id" {}

variable "ami_id" {}

variable "es_sg" {}

variable "zone_id" {
  description = "Sparta Education Zone ID"
  default="Z3CCIZELFLJ3SC"
}

variable "name" {
  default = "KB_Sec_Group"
}
