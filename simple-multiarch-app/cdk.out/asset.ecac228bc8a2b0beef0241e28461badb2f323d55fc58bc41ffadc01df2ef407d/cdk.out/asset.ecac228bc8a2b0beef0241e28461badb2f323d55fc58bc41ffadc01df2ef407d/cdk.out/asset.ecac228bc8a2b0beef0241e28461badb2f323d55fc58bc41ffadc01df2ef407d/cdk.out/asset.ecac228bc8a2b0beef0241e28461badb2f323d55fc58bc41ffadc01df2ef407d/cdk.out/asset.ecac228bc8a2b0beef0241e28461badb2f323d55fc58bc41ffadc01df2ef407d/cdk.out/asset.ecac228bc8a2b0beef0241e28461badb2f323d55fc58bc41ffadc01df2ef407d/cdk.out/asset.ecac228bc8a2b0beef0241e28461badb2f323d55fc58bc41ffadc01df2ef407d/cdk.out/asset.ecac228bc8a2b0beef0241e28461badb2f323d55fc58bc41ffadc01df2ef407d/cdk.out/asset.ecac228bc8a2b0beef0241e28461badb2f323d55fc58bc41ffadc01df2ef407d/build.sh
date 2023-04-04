#!/bin/bash -x
APP_IMAGE=$AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$APP_IMAGE_NAME:$APP_IMAGE_TAG
aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $APP_IMAGE
docker build -t $APP_IMAGE .
docker push $APP_IMAGE
