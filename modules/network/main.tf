


resource "aws_default_vpc" "vvv_vpc" {
  
  tags = {
    Name = var.project
  }

}
resource "aws_default_subnet" "vvv_subnet_a" {
  availability_zone = "${var.region}a"
  
    tags = {
    Name = "${var.project}_a"
  }
}
resource "aws_default_subnet" "vvv_subnet_b" {
   availability_zone = "${var.region}b"
      tags = {
       Name = "${var.project}_b"
      }
}
resource "aws_default_subnet" "vvv_subnet_c" {
  availability_zone = "${var.region}c"
      tags = {
      Name = "${var.project}_c"
    }
}