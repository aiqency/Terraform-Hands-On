variable "num_of_subnet" {}
variable "subnet_ids" {
  type = "list"
}
variable "public_rt_id" {}
variable "private_rt_id" {}

resource "aws_route_table_association" "public_assoc" {
  count           = "${var.num_of_subnet/2}"
  subnet_id       = "${element(slice(var.subnet_ids, 0, var.num_of_subnet/2), count.index)}"
  route_table_id  = "${var.public_rt_id}"
}

resource "aws_route_table_association" "private_assoc" {
  count           = "${var.num_of_subnet/2}"
  subnet_id       = "${element(slice(var.subnet_ids, var.num_of_subnet/2, var.num_of_subnet), count.index)}" #slice(list, from, to)
  route_table_id  = "${var.private_rt_id}"
}
