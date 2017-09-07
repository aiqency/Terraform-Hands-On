variable "ssh_key" {}
variable "num_of_subnet" {}
variable "private_ssh_key_path"{}
variable "subnets_ids"{
  type = "list"
}

module "sg" {
  source = "../sg"
}

resource "aws_instance" "my_instance" {
  count                   = "${var.num_of_subnet}" # one instance per subnet
  ami                     = "ami-4fffc834"
  instance_type           = "t2.micro"
  key_name                = "${var.ssh_key}"
  subnet_id               = "${element(var.subnets_ids, count.index)}"
  vpc_security_group_ids  = [ "${module.sg.allow_all}"]
  connection {
      type                = "ssh"
      user                = "ec2-user"
      private_key         = "${file("${var.private_ssh_key_path}")}"
      agent               = false
  }
  provisioner "remote-exec" {
    inline = [
      "sudo yum -y update",
      "sudo yum install -y docker",
      "sudo service docker start",
      "sudo usermod -a -G docker ec2-user"
    ]
  }
  tags {
    Name = "Node_${element(var.subnets_ids, count.index)}"
  }
}
