#!/bin/bash -x

if [ -z "$AWS_REGION" ]
then
  echo "missing" AWS_REGION
  exit
fi
if [ -z "$AWS_ACCOUNT_ID" ]
then
  echo "missing" AWS_ACCOUNT_ID
  exit
fi
if [ -z "$INSTANCE_ARCH" ]
then
  echo "missing" INSTANCE_ARCH
  exit
fi

echo AWS_REGION=$AWS_REGION AWS_ACCOUNT_ID=$AWS_ACCOUNT_ID INSTANCE_ARCH=$INSTANCE_ARCH

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
