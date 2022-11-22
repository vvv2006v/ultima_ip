variable "region" {
  type        = string
  default     = "us-east-1"
  
}
variable "project" {
  type        = string
  default     = "ultima"
  
}
variable "default_subnet_a_id" {}
variable "default_subnet_b_id" {}
variable "default_subnet_c_id" {}
variable "default_vpc_id" {}
variable "target_group_arn" {}
variable "vvv_service_security_group_id" {}

