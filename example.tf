provider "aws" {
	region = "eu-west-2"
}

resource "aws_instance" "example" {
	ami = "ami-c0998ca4"
	instance_type = "t2.micro"
}

resource "aws_eip" "ip" {
	instance = "${aws_instance.example.id}"
        depends_on = ["aws_instance.example"]
}
