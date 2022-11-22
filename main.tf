provider "aws"  {}

module network {
  source             = "./modules/network"
  region             = var.region
  project            = var.project
}

module load_balancer {
  source             = "./modules/load_balancer"
  region             = var.region
  project            = var.project
  sslcertificate     = var.sslcertificate
  default_vpc_id     = module.network.default_vpc_id
  default_subnet_a_id= module.network.default_subnet_a_id
  default_subnet_b_id= module.network.default_subnet_b_id
  default_subnet_c_id= module.network.default_subnet_c_id

}


module ecs_container {
  source               = "./modules/ecs_container"
  region                        = var.region
  project                       = var.project
  default_vpc_id                = module.network.default_vpc_id
  default_subnet_a_id           = module.network.default_subnet_a_id
  default_subnet_b_id           = module.network.default_subnet_b_id
  default_subnet_c_id           = module.network.default_subnet_c_id
  target_group_arn              = module.load_balancer.lb_target_group_arn
  vvv_service_security_group_id = module.load_balancer.vvv_service_security_group_id
 
}



/*
module network {
  source = "./modules/network"
  param  = value
}
module ecs_container {
  source = "./modules/ecs_container"
  param  = value
}
module load_balancer {
  source = "./modules/load_balancer"
  param  = value
}

*/
/*
resource "aws_default_vpc" "vvv_vpc" {
  
  tags = {
    Name = "${"var.project"}_VPC"
  }
}
resource "aws_default_subnet" "vvv_subnet_a" {
  availability_zone = "${var.region}a"
  
    tags = {
    Name = "${"var.project"}a"
  }
}
resource "aws_default_subnet" "vvv_subnet_b" {
   availability_zone = "${var.region}b"
      tags = {
       Name = "${"var.project"}b"
      }
}
resource "aws_default_subnet" "vvv_subnet_c" {
  availability_zone = "${var.region}c"
      tags = {
      Name = "${"var.project"}c"
    }
}
*/
/*
resource "aws_ecs_cluster" "vvv_cluster" {
  name = "vvv-cluster" # my-cluster   Naming the cluster
}
resource "aws_ecs_task_definition" "vvv_task" {

 family                   = "vvv-task" # Naming our first task


  container_definitions    = <<DEFINITION
  [
    {
      "name": "vvv-task",
      "image": "docker.plcu.io/plc-vvv-node:3.13",
      "essential": true,
      "portMappings": [
        {
          "containerPort": 9332,
          "hostPort": 9332
        }
      ],
      "memory": 2048,
      "cpu": 1024
    }
  ]
  DEFINITION

  requires_compatibilities = ["FARGATE"] # Stating that we are using ECS Fargate
  network_mode             = "awsvpc"    # Using awsvpc as our network mode as this is required for Fargate
  memory                   = 2048        # Specifying the memory our container requires
  cpu                      = 1024        # Specifying the CPU our container requires
  #execution_role_arn       = "${aws_iam_role.vvv_ecs_TaskExecutionRole.arn}"
}
*/
/*
resource "aws_alb" "vvv_application_load_balancer" {
  name               = "lb-tf" # Naming our load balancer
  load_balancer_type = "application"



  subnets = [ # Referencing the default subnets
    "${aws_default_subnet.vvv_subnet_a.id}",
    "${aws_default_subnet.vvv_subnet_b.id}",
    "${aws_default_subnet.vvv_subnet_c.id}"
  ]

  # Referencing the security group
  security_groups = ["${aws_security_group.vvv_load_balancer_security_group.id}"]
  
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
  load_balancer_arn = "${aws_alb.vvv_application_load_balancer.arn}" # Referencing our load balancer
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.vvv_target_group.arn}" # Referencing our tagrte group
  }
}
resource "aws_lb_listener" "vvv_https_listener" {
  load_balancer_arn = "${aws_alb.vvv_application_load_balancer.arn}"
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = var.ssl-certificate
  # certificate_arn   = "arn:aws:acm:us-east-1:564141216590:certificate/3a2f0d25-ab5e-4c2f-9849-45509c87ff89"
  default_action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.vvv_target_group.arn}"
  }
}
resource "aws_lb_target_group" "vvv_target_group" {
  name        = "vvv-target-group"
  port        = 80
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = "${aws_default_vpc.vvv_vpc.id}" # Referencing the default VPC
}
resource "aws_ecs_service" "vvv_service" {
  name            = "vvv-service"                             # Naming our first service
  cluster         = "${aws_ecs_cluster.vvv_cluster.id}"             # Referencing our created Cluster
  task_definition = "${aws_ecs_task_definition.vvv_task.arn}" # Referencing the task our service will spin up
  launch_type     = "FARGATE"
  desired_count   = 1 # Setting the number of containers to 1

  load_balancer {
    target_group_arn = "${aws_lb_target_group.vvv_target_group.arn}" # Referencing our target group
    container_name   = "${aws_ecs_task_definition.vvv_task.family}"
    container_port   = 9332 # Specifying the container port
  }

  network_configuration {
    subnets          = ["${aws_default_subnet.vvv_subnet_a.id}", "${aws_default_subnet.vvv_subnet_b.id}", "${aws_default_subnet.vvv_subnet_c.id}"]
    assign_public_ip = true                                                # Providing our containers with public IPs
    security_groups  = ["${aws_security_group.vvv_service_security_group.id}"] # Setting the security group
  }


}
resource "aws_security_group" "vvv_service_security_group" {
  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    # Only allowing traffic in from the load balancer security group
    security_groups = ["${aws_security_group.vvv_load_balancer_security_group.id}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
data "dns_a_record_set" "lb_dns_a" {
  host  = "${aws_alb.vvv_application_load_balancer.dns_name}"
}
*/
/*
resource "aws_iam_role" "vvv_ecs_TaskExecutionRole" {
  name               = "${"var.project"}_ecs_TaskExecutionRole"
  assume_role_policy = "${data.aws_iam_policy_document.assume_role_policy.json}"
}
data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}
resource "aws_iam_role_policy_attachment" "vvv_ecsTaskExecutionRole_policy" {
  role       = "${aws_iam_role.vvv_ecs_TaskExecutionRole.name}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

*/
/*
resource "aws_route53_zone" "primary" {
  name = "fractal-academy1.com"
}
resource "aws_route53_record" "A" {
  allow_overwrite = true
  name    = "fractal-academy1.com"
  type = "A"
  zone_id = aws_route53_zone.primary.zone_id
 
   alias {
    name  = aws_alb.vvv_application_load_balancer.dns_name
    zone_id   = aws_alb.vvv_application_load_balancer.zone_id
    evaluate_target_health = true
  }
  
}
resource "aws_route53_record" "NS" {
  allow_overwrite = true
  name            = "fractal-academy1.com"
  ttl             = 60
  type            = "NS"
  zone_id         = aws_route53_zone.primary.zone_id

  records = [
    aws_route53_zone.primary.name_servers[0],
    aws_route53_zone.primary.name_servers[1],
    aws_route53_zone.primary.name_servers[2],
    aws_route53_zone.primary.name_servers[3],
  ]
}
*/