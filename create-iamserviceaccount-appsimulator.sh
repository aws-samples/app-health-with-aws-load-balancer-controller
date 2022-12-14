#!/bin/sh

echo "Configure iam access to repo and sqs"
aws iam create-policy \
    --policy-name appsimulatorIAMPolicy \
    --policy-document file://appsimulator_iam_policy.json

eksctl create iamserviceaccount \
  --cluster=lb-health-x86 \
  --namespace=default \
  --name=appsimulator \
  --role-name "appsimulatorRole" \
  --attach-policy-arn=arn:aws:iam::${AWS_ACCOUNT_ID}:policy/appsimulatorIAMPolicy \
  --approve
