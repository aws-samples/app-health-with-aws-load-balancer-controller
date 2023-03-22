#!/bin/sh
  
echo "Creating docker image repositories"
aws cloudformation create-stack --stack-name ecr-simple-multiarch-repo --template-body file://./ecr-simple-multiarch-repo.json
