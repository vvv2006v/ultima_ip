output "ip_node" {
  value = module.load_balancer.lb_ip
  }

output "subnet_a_id" {
  value       = module.network.default_subnet_a_id
}

output "subnet_b_id" {
  value       = module.network.default_subnet_b_id
}

output "subnet_c_id" {
  value       = module.network.default_subnet_c_id
}

  
output "vpc_id" {
  value       = module.network.default_vpc_id
  
     }
     
   