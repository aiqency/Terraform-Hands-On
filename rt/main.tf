variable "vpc_id" {}
variable "subnet_ids" {
  type = "list"
}
variable "num_of_subnet" {}
variable "igw_id" {}

module "rt_association" {
  source = "../association"
  subnet_ids = "${var.subnet_ids}"
  public_rt_id =  "${aws_route_table.public.id}"
  private_rt_id = "${aws_route_table.private.id}"
  num_of_subnet = "${var.num_of_subnet}"
}

# create an Eip for the nat gateway
resource "aws_eip" "nat" {
  vpc      = true
}

# Create the nat gateway
resource "aws_nat_gateway" "gw" {
  subnet_id = "${element(var.subnet_ids, 0)}"
  allocation_id = "${aws_eip.nat.id}"  # depends_on = ["aws_internet_gateway.gw"]
}
# Public RoutingTable route all traffic to the igw
resource "aws_route_table" "public" {
  vpc_id = "${var.vpc_id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${var.igw_id}"
  }

  tags {
    Name = "public_rt"
  }
}

# Private RoutingTable route all traffic to the nat gateway
resource "aws_route_table" "private" {
  vpc_id = "${var.vpc_id}"

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = "${aws_nat_gateway.gw.id}"
  }

  tags {
    Name = "private_rt"
  }
}
