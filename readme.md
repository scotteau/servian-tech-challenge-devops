# Servian Tech Challenge - DevOps

## Tools used
- Terraform
- AWS Cli
- Git
- Docker
- jq

## Architecture Diagram
![diagram](./files/diagram.png)

Components
- Application load balancer to receive and distribute traffic through to app servers
- App are hosted in AWS ECS Fargate across two AZs in the same region
- Database layer using RDS Aurora Postgres with read replica across AZs
- App image is hosted in ECR

##  Todos
- [x] Add application repo as a submodule 
- [x] Build a docker image for the app
- [x] Create ECR repository using AWS Cli
- [x] Push image to ECR

- [x] Provisioning Infrastructure in Terraform
  - [x] Networking
  - [x] Security Groups
  - [x] IAM roles
  - [x] Database
  - [x] Application Load Balancer
  - [x] ECS Fargate
- [ ] Seed the database