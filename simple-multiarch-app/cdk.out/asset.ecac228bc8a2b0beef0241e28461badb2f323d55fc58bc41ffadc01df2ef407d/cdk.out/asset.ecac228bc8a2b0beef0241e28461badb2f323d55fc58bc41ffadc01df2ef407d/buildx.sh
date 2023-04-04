#!/bin/bash -x
APP_IMAGE=$AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$APP_IMAGE_NAME:$APP_IMAGE_TAG
aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $APP_IMAGE
docker buildx use craftbuilder
docker buildx build --push --cache-to type=inline --cache-from type=registry,ref=$APP_IMAGE  --platform linux/arm64,linux/amd64 -t $APP_IMAGE .
