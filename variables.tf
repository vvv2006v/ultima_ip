variable "region" {
  type        = string
  default     = "us-east-1"

}
variable "project" {
  type        = string
  default     = "ultima"

}
variable "sslcertificate" {
  default     = "arn:aws:acm:us-east-1:564141216590:certificate/3a2f0d25-ab5e-4c2f-9849-45509c87ff89"
  
}
variable "port" {
  type        = number
  default     = 9332
  
}
variable "cpu" {
  type        = number
  default     = 1024
 
}
variable "memory" {
  type        = number
  default     = 2048
  
}

variable "image" {
  type        = string
  default     = "docker.plcu.io/plc-vvv-node:3.13"
}
variable "default_subnet_a_id" {
   default     = ""
}
variable "default_subnet_b_id" {
   default     = ""
}
variable "default_subnet_c_id" {
   default     = ""
}
variable "default_vpc_id" {
   default     = ""
}
variable "target_group_arn" {
   default     = ""
}
variable "vvv_service_security_group_id" {
   default     = ""
}




