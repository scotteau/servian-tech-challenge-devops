################################################################################
# ecs-fargate
################################################################################

variable "ecr_repository_url" {
  description = "The repository url of preferred docker image within ECR"
  type        = string
}

resource "aws_ecs_cluster" "server" {
  name = "${local.prefix}-cluster"
}

resource "aws_ecs_task_definition" "server" {
  family                   = var.project_name
  requires_compatibilities = ["FARGATE"]
  cpu                      = "1024"
  memory                   = "2048"
  network_mode             = "awsvpc"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn

  runtime_platform {
    cpu_architecture        = "X86_64"
    operating_system_family = "LINUX"
  }
  ephemeral_storage {
    size_in_gib = 30
  }

  container_definitions = templatefile(
    "${path.root}/files/container_definition.json.tftpl",
    {
      name       = "${local.prefix}-server"
      image      = "${var.ecr_repository_url}:latest"
      region     = var.region
      DbUser     = aws_ssm_parameter.DB_USER.arn
      DbPassword = aws_ssm_parameter.DB_PASSWORD.arn
      DbName     = aws_ssm_parameter.DB_NAME.arn
      DbPort     = aws_ssm_parameter.DB_PORT.arn
      DbHost     = aws_ssm_parameter.DB_HOST.arn
      DbType     = "postgres"
      ListenHost = "0.0.0.0"
      PORT       = var.PORT
  })

  depends_on = [module.rds_aurora.cluster_arn]

  tags = merge(local.default_tags, {
    Name = "${local.prefix}-task-definition"
  })
}

resource "aws_ecs_service" "service" {

  name            = "${local.prefix}-ecs-service"
  cluster         = aws_ecs_cluster.server.id
  task_definition = aws_ecs_task_definition.server.arn
  desired_count   = 2
  launch_type     = "FARGATE"

  load_balancer {
    container_name   = "${local.prefix}-server"
    container_port   = var.PORT
    target_group_arn = aws_alb_target_group.ecs.arn
  }

  network_configuration {
    subnets          = aws_subnet.server[*].id
    security_groups  = [aws_security_group.ecs.id]
  }

  tags = merge(local.default_tags, { Name = "${local.prefix}-service" })
}

output "task-definition" {
  value = aws_ecs_task_definition.server.arn
}

output "ecs-cluster" {
  value = aws_ecs_cluster.server.arn
}

output "ecs-sgs" {
  value = [aws_security_group.ecs.id]
}

output "ecs-subnets" {
  value = aws_subnet.server[*].id
}
