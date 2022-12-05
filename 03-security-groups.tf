################################################################################
# Security Group
################################################################################
variable "database_ingress_ports" {
  description = "Ports opened for database"
  type        = list(number)
}

variable "ecs_ingress_ports" {
  description = "Ports opened for ECS"
  type        = list(number)
}

variable "alb_ingress_ports" {
  description = "Ports opened for ALB"
  type        = list(number)
}

# Security Group - ECS
resource "aws_security_group" "ecs" {
  vpc_id = aws_vpc.main.id

  dynamic "ingress" {
    for_each = var.ecs_ingress_ports
    content {
      from_port       = ingress.value
      to_port         = ingress.value
      protocol        = "tcp"
      security_groups = [aws_security_group.alb.id]
    }
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = merge(local.default_tags, { Name = "${local.prefix}-sg-ecs" })
}

# Security Group - ALB
resource "aws_security_group" "alb" {
  vpc_id = aws_vpc.main.id

  dynamic "ingress" {
    for_each = var.alb_ingress_ports
    content {
      from_port        = ingress.value
      to_port          = ingress.value
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
    }
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = merge(local.default_tags, { Name = "${local.prefix}-sg-alb" })
}

# Security Group - Database
resource "aws_security_group_rule" "ecs_access" {
  type                     = "ingress"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  security_group_id        = module.rds_aurora.security_group_id
  source_security_group_id = aws_security_group.ecs.id
}
