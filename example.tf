provider "aws" {
	region = "eu-west-2"
}

resource "aws_vpc" "default" {
  cidr_block = "10.0.0.0/16"
}

# Create an internet gateway to give our subnet access to the outside world
resource "aws_internet_gateway" "default" {
  vpc_id = "${aws_vpc.default.id}"
}

# Grant the VPC internet access on its main route table
resource "aws_route" "internet_access" {
  route_table_id         = "${aws_vpc.default.main_route_table_id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.default.id}"
}

# Create a subnet to launch our instances into
resource "aws_subnet" "default" {
  vpc_id                  = "${aws_vpc.default.id}"
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
}

resource "aws_key_pair" "auth" {
  key_name   = "${var.key_name}"
  public_key = "${file(var.public_key_path)}"
}

resource "aws_eip" "ip" {
	instance = "${aws_instance.example.id}"
        depends_on = ["aws_instance.example"]
}


resource "aws_security_group" "default" {
	name = "terraform_example"
	description = "Used in the terraform example"
	vpc_id = "${aws_vpc.default.id}"

	ingress {
		from_port = 22
		to_port = 22
		protocol = "tcp"
		cidr_blocks = ["0.0.0.0/0"]
	}

	egress {
		from_port = 0
		to_port = 0
		protocol = "-1"
		cidr_blocks = ["0.0.0.0/0"]
	}
}

resource "aws_instance" "example" {
	connection {
		user = "ubuntu"
	}
	ami = "ami-c0998ca4"

	instance_type = "t2.micro"

	# The name of our SSH keypair we created above.
  key_name = "${aws_key_pair.auth.id}"

  # Our Security group to allow HTTP and SSH access
  vpc_security_group_ids = ["${aws_security_group.default.id}"]

	subnet_id = "${aws_subnet.default.id}"

	provisioner "local-exec" {
		command = "echo ${aws_instance.example.public_ip} > ip_address.txt"
	}
}



output "Public IP Address" {
	value = "${aws_eip.ip.public_ip}"
}
