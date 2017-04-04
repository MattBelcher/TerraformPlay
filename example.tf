provider "aws" {
	region = "eu-west-2"
}

resource "aws_instance" "example" {
	ami = "ami-f1949e95"
	instance_type = "t2.micro"
}
