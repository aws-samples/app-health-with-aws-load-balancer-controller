#!/bin/bash -x

IMAGE=$AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$APP_IMAGE_NAME:$APP_IMAGE_NAME
ARM_IMAGE=$AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$APP_IMAGE_NAME:$APP_IMAGE_ARM_TAG
AMD_IMAGE=$AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$APP_IMAGE_NAME:$APP_IMAGE_AMD_TAG
aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $IMAGE

docker manifest create $IMAGE --amend $ARM_IMAGE --amend $AMD_IMAGE
docker manifest push $IMAGE
