aws ecs run-task \
--cluster "$(terraform output ecs-cluster | tr -d '"' | cut -d/ -f2)"  \
--launch-type="FARGATE" \
--task-definition "$(terraform output task-definition | tr -d '"' | cut -d/ -f2)" \
--network-configuration "{ \"awsvpcConfiguration\": { \"securityGroups\": $(terraform output ecs-sgs | tr -d '\n' | tr -d ' ' | tr -d ','), \"subnets\": $(terraform output ecs-subnets | tr -d '\n' | tr -d ' ' | sed 's/\(.*\),/\1/')}}" \
--overrides '{ "containerOverrides": [{"name": "servian-tc-server", "command": ["updatedb","-s"]}]}'