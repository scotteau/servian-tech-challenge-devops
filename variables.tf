variable "region" {
  default = "ap-southeast-2"
}

variable "project_name" {
  default = "servian-tc"
}

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

locals {
  default_tags = {
    ManagedBy = "Terraform"
    Project   = var.project_name
  }

  prefix = var.project_name
  azs    = ["2a", "2b"]
}
