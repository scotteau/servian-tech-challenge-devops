################################################################################
# RDS aurora postgres
################################################################################

module "rds_aurora" {
  source  = "terraform-aws-modules/rds-aurora/aws"
  version = "7.6.0"


  name           = "${local.prefix}-db-postgres"
  engine         = "aurora-postgresql"
  engine_version = "13.8"
  instance_class = "db.t4g.medium"

  instances = {
    one = {
      publicly_accessible = true
    }
    two = {}
  }

  vpc_id                 = aws_vpc.main.id
  db_subnet_group_name   = aws_db_subnet_group.aurora_postgres.name
  create_db_subnet_group = false
  create_security_group  = true
  allowed_cidr_blocks    = aws_subnet.server[*].cidr_block


  iam_database_authentication_enabled = true
  master_username                     = aws_ssm_parameter.DB_USER.value
  master_password                     = aws_ssm_parameter.DB_PASSWORD.value
  create_random_password              = false

  apply_immediately   = true
  skip_final_snapshot = true

  db_parameter_group_name         = aws_db_parameter_group.postgres_13.id
  db_cluster_parameter_group_name = aws_rds_cluster_parameter_group.postgres_13.id
  enabled_cloudwatch_logs_exports = ["postgresql"]

  tags = merge(local.default_tags, { Name = "${local.prefix}-aurora-postgres" })
}

resource "random_password" "db_password" {
  length  = 12
  special = false
}


resource "aws_db_parameter_group" "postgres_13" {
  name        = "${local.prefix}-aurora-db-postgres13-parameter-group"
  family      = "aurora-postgresql13"
  description = "${local.prefix}-aurora-db-postgres13-parameter-group"
  tags        = local.default_tags
}

resource "aws_rds_cluster_parameter_group" "postgres_13" {
  name        = "${local.prefix}-aurora-postgres13-cluster-parameter-group"
  family      = "aurora-postgresql13"
  description = "${local.prefix}-aurora-postgres13-cluster-parameter-group"
  tags        = local.default_tags
}

resource "aws_db_subnet_group" "aurora_postgres" {
  name       = "aurora_postgres"
  subnet_ids = aws_subnet.database[*].id

  tags = local.default_tags
}

# db variables
variable "db_name" {
  type = string
}

variable "master_username" {
  type = string
}


resource "aws_ssm_parameter" "DB_USER" {
  name  = "/APP/DB_USER"
  type  = "String"
  value = var.master_username
}

resource "aws_ssm_parameter" "DB_PASSWORD" {
  name  = "/APP/DB_PASSWORD"
  type  = "SecureString"
  value = random_password.db_password.result
}

resource "aws_ssm_parameter" "DB_TYPE" {
  name  = "/APP/DB_TYPE"
  type  = "String"
  value = "postgres"
}

resource "aws_ssm_parameter" "DB_HOST" {
  name  = "/app/DB_HOST"
  type  = "SecureString"
  value = local.host
}

resource "aws_ssm_parameter" "DB_NAME" {
  name  = "/APP/DB_NAME"
  type  = "String"
  value = "app"
}

locals {
  protocol    = "postgresql"
  DB_USER     = aws_ssm_parameter.DB_USER.value
  DB_PASSWORD = aws_ssm_parameter.DB_PASSWORD.value
  host        = module.rds_aurora.cluster_endpoint
  port        = module.rds_aurora.cluster_port
}



output "endpoint" {
  value = module.rds_aurora.cluster_endpoint
}