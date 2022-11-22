output "lb_ip" {
  value = "${data.dns_a_record_set.lb_dns_a.addrs[0]}"
}

output "lb_target_group_arn" {
  value = "${aws_lb_target_group.vvv_target_group.arn}"
}

output "vvv_service_security_group_id" {
  value       = "${aws_security_group.vvv_service_security_group.id}"
  
}

