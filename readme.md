# Servian Tech Challenge - DevOps

## Tools used
- Terraform
- AWS Cli
- Git
- Docker
- jq
- Bash

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
- [x] Seed the database

- [x] Instructions on how to use the project
- [x] Better console output for user experience

## How to run the project
```shell
# initialise the project
make init
```

```shell
# create the ecr repo
make create_ecr_repo
```

```shell
# Prepare the payload before deployment
make prepare
```

```shell
# Deploy infrastructure & payload
make deploy
```

```shell
# Seeding the db
make seed
```

```shell
# Tear down
make destroy
```

```shell
# one command to spin up everything
make start
```

## More ideas
- Refactor terraform components into modules for better reusability
- Create tests for terraform modules
- Migrate makefile logic to CI/CD pipeline
- Move state to a remote backend
- Map a domain to load balancer dns name in route53 & enable HTTPS for connection