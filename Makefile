init:
	git submodule update
	terraform init

build: TechChallengeApp
	cd ./TechChallengeApp; docker build --build-arg arch=amd64 -t servian-tc-app:latest .

pull:
	docker pull servian/techchallengeapp:latest
	docker tag servian/techchallengeapp:latest servian-tc-app:latest

create_ecr_repo:
	aws ecr create-repository --repository-name servian-tc-app > ./files/ecr_repo.json

delete_ecr_repo:
	aws ecr delete-repository --repository-name servian-tc-app --force > /dev/null

push:
	AWS_ACCOUNT_ID=$$(cat files/ecr_repo.json | jq -r '.repository .registryId'); \
	REPO_URI=$$(cat files/ecr_repo.json | jq -r '.repository .repositoryUri'); \
	aws ecr get-login-password --region ap-southeast-2 | docker login --username AWS --password-stdin $$AWS_ACCOUNT_ID.dkr.ecr.ap-southeast-2.amazonaws.com; \
	docker tag servian-tc-app:latest $$REPO_URI:latest; \
	docker push $$REPO_URI:latest

append:
	echo "ecr_repository_url=\"$$(cat files/ecr_repo.json | jq -r '.repository .repositoryUri')\"\n" >> terraform.tfvars

prepare: pull push append

deploy:
	terraform apply --auto-approve

seed:
	chmod +x ./files/seed.sh; \
	files/seed.sh &> /dev/null; \
	echo "seeding the database..."; \
	echo "app is available at http://$$(terraform output app_url | tr -d '\"')";

destroy:
	terraform destroy

start: init create_ecr_repo prepare deploy seed