init:
	git submodule update
	terraform init

build: TechChallengeApp
	cd ./TechChallengeApp; docker build --build-arg arch=arm64 -t servian-tc-app:latest .

create_ecr_repo:
	aws ecr create-repository --repository-name servian-tc-app > ./files/ecr_repo.json

prepare: build create_ecr_repo