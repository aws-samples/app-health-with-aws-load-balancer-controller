#!/bin/sh
  
echo "Creating docker image repositories"
aws cloudformation create-stack --stack-name ecr-django-repos --template-body file://./ecr-django-app-repos.json
aws cloudformation create-stack --stack-name ecr-load-simu-repos --template-body file://./ecr-load-simu-repos.json
