init:
	git submodule update
	terraform init

build: TechChallengeApp
	cd ./TechChallengeApp; docker build --build-arg arch=arm64 -t servian-tc-app:latest .

prepare: build