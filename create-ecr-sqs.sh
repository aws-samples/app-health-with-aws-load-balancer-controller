#!/bin/sh
  
echo "Creating docker image repositoriesi and sqs queues"
aws cloudformation create-stack --stack-name ecr-django-repos --template-body file://./ecr-django-app-repos.json
aws cloudformation create-stack --stack-name ecr-load-simu-repos --template-body file://./ecr-load-simu-repos.json
aws cloudformation create-stack --stack-name sqs-load-simu-queue --template-body file://./sqs-load-simu-queue.json
aws cloudformation create-stack --stack-name sqs-app-load-simu-queue --template-body file://./sqs-app-load-simu-queue.json
