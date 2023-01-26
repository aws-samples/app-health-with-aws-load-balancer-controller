#!/bin/sh
  
echo "Deleting docker image repositories"
aws cloudformation delete-stack --stack-name ecr-django-repos 
aws cloudformation delete-stack --stack-name ecr-load-simu-repos 
