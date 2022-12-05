# General
variable "region" {
  default = "ap-southeast-2"
}

variable "project_name" {
  default = "servian-tc"
}

locals {
  default_tags = {
    ManagedBy = "Terraform"
    Project   = var.project_name
  }

  prefix = var.project_name
  azs    = ["2a", "2b"]
}

# Network
variable "public" {
  type    = list(string)
  default = ["10.0.101.0/24", "10.0.102.0/24"]
}

variable "servers" {
  type    = list(string)
  default = ["10.0.11.0/24", "10.0.12.0/24"]
}

variable "database" {
  type    = list(string)
  default = ["10.0.21.0/24", "10.0.22.0/24"]
}

# Database
variable "db_name" {
  type = string
  default = "app"
}

variable "master_username" {
  type = string
  default = "postgres"
}

# Security Groups
variable "database_ingress_ports" {
  description = "Ports opened for database"
  type        = list(number)
  default = [5432]
}

variable "ecs_ingress_ports" {
  description = "Ports opened for ECS"
  type        = list(number)
  default = [3000]
}

variable "alb_ingress_ports" {
  description = "Ports opened for ALB"
  type        = list(number)
  default = [80]
}

variable "PORT" {
  default = 3000
}
