
  output ecs_cluster_id{
    value       = "${aws_ecs_cluster.vvv_cluster.id}"
  }
   output ecs_task_arn {
    value       = "${aws_ecs_task_definition.vvv_task.arn}"
  }
   output ecs_task_family {
    value       = "${aws_ecs_task_definition.vvv_task.family}"
    
  }
  