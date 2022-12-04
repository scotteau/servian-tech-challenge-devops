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

- [ ] Provisioning Infrastructure in Terraform
  - [x] Networking
  - [ ] Security Groups
  - [ ] IAM roles
  - [ ] Database
  - [ ] Application Load Balancer
  - [ ] ECS Fargate