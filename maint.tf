variable "access_key" {}
variable "secret_key" {}
variable "ssh_key" {}
variable "private_ssh_key_path"{}

variable "vpc_id" {}
variable "igw_id" {}

variable "num_of_subnet" {}

variable "aws_region"{
  default = "us-east-1"
}

variable "av_zones"{
  default = [ "us-east-1a", "us-east-1b" ]
}

provider "aws" {
  access_key            = "${var.access_key}"
  secret_key            = "${var.secret_key}"
  region                = "${var.aws_region}"
}

module "instances" {
  source                = "./instances"
  ssh_key               = "${var.ssh_key}"
  num_of_subnet         = "${var.num_of_subnet}"
  private_ssh_key_path  = "${var.private_ssh_key_path}"
  subnets_ids            = "${aws_subnet.subnets.*.id}"
}

module "rt" {
  source                = "./rt"
  subnet_ids            = "${aws_subnet.subnets.*.id}"
  vpc_id                = "${var.vpc_id}"
  num_of_subnet         = "${var.num_of_subnet}"
  igw_id                = "${var.igw_id}"
}


resource "aws_subnet" "subnets" {
  count             = "${var.num_of_subnet}"
  vpc_id            = "${var.vpc_id}"
  availability_zone = "${element(var.av_zones, count.index % length(var.av_zones))}"
  cidr_block        = "172.31.${count.index}.0/24"   # "${cidrsubnet(data.aws_vpc.selected.cidr_block, 8, 1)}"
  map_public_ip_on_launch = true
  tags {
      Name = "Subnet_${count.index}"
  }
}

output "subnet_ids" {
  value = "${aws_subnet.subnets.*.id}"
}
