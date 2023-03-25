#!/bin/sh
  
echo "Creating docker image repositories and sqs queues"
aws cloudformation create-stack --stack-name ecr-simple-multiarch-repo --template-body file://./ecr-simple-multiarch-repo.json
aws cloudformation create-stack --stack-name ecr-load-simu-repos --template-body file://./ecr-load-simu-repos.json
aws cloudformation create-stack --stack-name sqs-arm-app-queue --template-body file://./sqs-arm-app-queue.json
aws cloudformation create-stack --stack-name sqs-amd-app-queue --template-body file://./sqs-amd-app-queue.json
