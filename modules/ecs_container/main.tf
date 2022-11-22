
resource "aws_ecs_cluster" "vvv_cluster" {
  name = "vvv-cluster" # my-cluster   Naming the cluster
}
resource "aws_ecs_task_definition" "vvv_task" {

 family                   = "vvv-task" # Naming our first task
  container_definitions    = <<DEFINITION
  [
    {
      "name": "vvv-task",
      "image": "docker.plcu.io/plc-ultima-node:3.13",
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
  #execution_role_arn       = "${aws_iam_role.vvv_ecs_TaskExecutionRole.arn}"               #!!!
}
/*
resource "aws_iam_role" "vvv_ecs_TaskExecutionRole" {
  name               = "${var.project}_ecs_TaskExecutionRole"
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
resource "aws_ecs_service" "vvv_service" {
  name            = "vvv-service"                           
  cluster         = "${aws_ecs_cluster.vvv_cluster.id}"             # Referencing our created Cluster            
  #cluster         = module.ecs_container.ecs_cluster_id       
  task_definition = "${aws_ecs_task_definition.vvv_task.arn}" # Referencing the task our service will spin up   
  #task_definition = module.ecs_container.ecs_task_arn
  launch_type     = "FARGATE"
  desired_count   = 3 # Setting the number of containers to 1

  load_balancer {
    #target_group_arn = "${aws_lb_target_group.vvv_target_group.arn}" # Referencing our target group
    target_group_arn= var.target_group_arn
    # target_group_arn =  "${module.load_balancer.lb_target_group_arn}"
    # Referencing our target group
     #target_group_arn = var.lb_tg_arn 
     container_name   = "${aws_ecs_task_definition.vvv_task.family}"  
     #container_name   = module.ecs_container.ecs_task_family                                         
     container_port   = 9332 # Specifying the container port
  }

  network_configuration {
  
   # subnets          = ["${aws_default_subnet.vvv_subnet_a.id}", "${aws_default_subnet.vvv_subnet_b.id}", "${aws_default_subnet.vvv_subnet_c.id}"]
    subnets           = [var.default_subnet_a_id, 
                         var.default_subnet_b_id,
                         var.default_subnet_c_id
                         ]     
                     
    
    assign_public_ip = true                                                # Providing our containers with public IPs
    #security_groups  = ["${var.vvv_service_security_group_id}"]  # Setting the security group #internal 
    security_groups  = [var.vvv_service_security_group_id] 
  }

}

/*

resource "aws_ecs_cluster" "vvv_cluster" {
  name = "vvv-cluster"  
}
resource "aws_ecs_task_definition" "vvv_task" {

  family                   = "vvv-task"  
  requires_compatibilities = ["FARGATE"]# Stating that we are using ECS Fargate
  network_mode             = "awsvpc"    # Using awsvpc as our network mode as this is required for Fargate
  memory                   = var.memory       # Specifying the memory our container requires
  cpu                      = var.cpu        # Specifying the CPU our container requires
  execution_role_arn       = "${aws_iam_role.vvv_ecs_TaskExecutionRole.arn}"
  container_definitions    = <<DEFINITION
  [
    {
      "name": "ultima-task",
      "image": "docker.plcu.io/plc-ultima-node:3.13",
      "essential": true,
      "portMappings": [
        {
          "containerPort": 9332,
          "hostPort": 9332
        }
      ],
      "memory": 2048,
      "cpu": 512
    }
  ]
  DEFINITION

}
*/
/*
  container_definitions    = <<DEFINITION
  [
    {
      "name": "vvv-task",
      "image": var.image,
      "essential": true,
      "portMappings": [
        {
          "containerPort": var.port,
          "hostPort": var.port
        }
      ],
      "memory": var.memory,
      "cpu": var.cpu
    }
  ]
  DEFINITION
*/