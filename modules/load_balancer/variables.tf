variable "region" {
  type        = string
  default     = "us-east-1"
  description = "region Name"
}
variable "project" {
  type        = string
  default     = "ultima"
  description = "name of the project"
}


variable "sslcertificate" {
  type        = string
  default     = "arn:aws:acm:us-east-1:564141216590:certificate/3a2f0d25-ab5e-4c2f-9849-45509c87ff89"
}
variable "default_subnet_a_id" {}
variable "default_subnet_b_id" {}
variable "default_subnet_c_id" {}
variable "default_vpc_id" {}


