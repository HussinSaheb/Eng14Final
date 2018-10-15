#setting the provider in this case AWS
provider "aws" {
  region ="eu-west-1"
}

# 1 - terraform
# Creating a VPC
resource "aws_vpc" "Eng14vpc" {
  cidr_block = "10.0.0.0/16"
  tags {
    Name = "${var.name}-vpc"
  }
}

resource "aws_internet_gateway" "app" {
  vpc_id = "${aws_vpc.Eng14vpc.id}"

  tags {
    Name = "Eng14IG"
  }
}

data "template_file" "app_init" {
   template = "${file("./scripts/app/init.sh.tpl")}"
   vars {
      db_host="mongodb://${module.db.db_instance}:27017/posts"
   }
}

module "app" {
  source = "./modules/app_tier"
  ig_id = "${aws_internet_gateway.app.id}"
  vpc_id = "${aws_vpc.Eng14vpc.id}"
  user_data = "${data.template_file.app_init.rendered}"
  ami = "${var.app_ami}"
}


#Module for the DB
module "db" {
  source = "./modules/db_tier"
  vpc_id = "${aws_vpc.Eng14db.id}"
  name = "${var.name}"
  region = "${var.dbregion1}"
  db_ami_id = "${var.db_ami}"
  app_sg = "${module.app.security_group_id}"
  app_subnet_cidr_block = "${module.app.subnet_cidr_block}"
}
