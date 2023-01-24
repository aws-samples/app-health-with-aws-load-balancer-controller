#!/bin/bash -x

IMAGE_REPO=$AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$LOAD_IMAGE_NAME:$LOAD_IMAGE_TAG
aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin $IMAGE_REPO
docker buildx use builder
docker buildx build --push --platform linux/arm64,linux/amd64 -t $IMAGE_REPO .
