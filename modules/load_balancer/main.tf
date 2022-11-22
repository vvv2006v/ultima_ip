
resource "aws_alb" "vvv_application_load_balancer" {
  name               = "lb-tf" # Naming our load balancer
  load_balancer_type = "application"

  subnets = [
    var.default_subnet_a_id, 
    var.default_subnet_b_id, 
    var.default_subnet_c_id
   # "${var.default_subnet_a_id}", 
    #"${var.default_subnet_b_id}", 
   # "${var.default_subnet_c_id}"
  ]
  #  "${aws_default_subnet.vvv_subnet_a.id}",    # output from module network
  #  "${aws_default_subnet.vvv_subnet_b.id}",    # output from module network
  #  "${aws_default_subnet.vvv_subnet_c.id}"     # output from module network
  # Referencing the security group
  security_groups = ["${aws_security_group.vvv_load_balancer_security_group.id}"]  #internal
  
}
resource "aws_security_group" "vvv_load_balancer_security_group" {
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Allowing traffic in from all sources
  }
  ingress {
    description = "Allow Port 443"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
resource "aws_lb_listener" "vvv_listener" {
  load_balancer_arn = "${aws_alb.vvv_application_load_balancer.arn}" # Referencing our load balancer  - #internal
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.vvv_target_group.arn}" # Referencing our tagrte group -#internal
  }
}
resource "aws_lb_listener" "vvv_https_listener" {
  load_balancer_arn = "${aws_alb.vvv_application_load_balancer.arn}"
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = var.sslcertificate   #internal
  # certificate_arn   = "arn:aws:acm:us-east-1:564141216590:certificate/3a2f0d25-ab5e-4c2f-9849-45509c87ff89"
  default_action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.vvv_target_group.arn}"  #internal
  }
}
resource "aws_lb_target_group" "vvv_target_group" {
  name        = "vvv-target-group"
  port        = 80
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = var.default_vpc_id
  #vpc_id      = "${aws_default_vpc.vvv_vpc.id}" # Referencing the default VPC       # output from module network
}
/* удалить после отладки */
/*
resource "aws_ecs_service" "vvv_service" {
  name            = "vvv-service"                           
 # cluster         = "${aws_ecs_cluster.vvv_cluster.id}"             # Referencing our created Cluster            # output from module ecs_container
  cluster         = module.ecs_container.ecs_cluster_id       
  #task_definition = "${aws_ecs_task_definition.vvv_task.arn}" # Referencing the task our service will spin up    # output from module ecs_container
  task_definition = module.ecs_container.ecs_task_arn
  launch_type     = "FARGATE"
  desired_count   = 1 # Setting the number of containers to 1

  load_balancer {
    target_group_arn = "${aws_lb_target_group.vvv_target_group.arn}" # Referencing our target group
     #container_name   = "${aws_ecs_task_definition.vvv_task.family}"  
     container_name   = module.ecs_container.ecs_task_family                                         # output from module ecs_container
     container_port   = var.port # Specifying the container port
  }

  network_configuration {
     # output from module network
   # subnets          = ["${aws_default_subnet.vvv_subnet_a.id}", "${aws_default_subnet.vvv_subnet_b.id}", "${aws_default_subnet.vvv_subnet_c.id}"]
    subnets          = [module.network.default_subnet_a_id, 
                       module.network.default_subnet_b_id, 
                       module.network.default_subnet_a_id]
    
    assign_public_ip = true                                                # Providing our containers with public IPs
    security_groups  = ["${aws_security_group.vvv_service_security_group.id}"] # Setting the security group #internal 
  }

}
*/
resource "aws_security_group" "vvv_service_security_group" {
  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    # Only allowing traffic in from the load balancer security group
    security_groups = ["${aws_security_group.vvv_load_balancer_security_group.id}"]   #internal
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
data "dns_a_record_set" "lb_dns_a" {
  host  = "${aws_alb.vvv_application_load_balancer.dns_name}"                         #internal
}