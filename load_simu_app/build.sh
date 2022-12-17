#!/bin/bash

repo="loader"
repo_name='.dkr.ecr.'${AWS_REGION}'.amazonaws.com/'$repo':py39'${INSTANCE_ARCH}'64'
repo_url=${AWS_ACCOUNT_ID}$repo_name

if [[ "${INSTANCE_ARCH}" == "arm" ]]; then
  ARCH="aarch64"
elif [[ "${INSTANCE_ARCH}" == "amd" ]]; then
  ARCH="x86_64"
else
  echo "INSTANCE_ARCH is not compatible :" $INSTANCE_ARCH
fi
aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin $repo_url
docker build --build-arg ARCH=$ARCH  -t $repo_url .
docker push $repo_url
