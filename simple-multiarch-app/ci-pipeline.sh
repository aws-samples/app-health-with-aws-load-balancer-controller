#!/bin/bash

npm install aws-cdk-lib
. ~/.bash_profile
cdk bootstrap aws://$AWS_ACCOUNT_ID/$AWS_REGION
npm install
cdk deploy \
--app "npx ts-node --prefer-ts-exts ./ci-pipeline.ts" --parameters BUILDXVER=$BUILDX_VER --parameters APPIMAGENAME=$APP_IMAGE_NAME --parameters APPIMAGETAG=$APP_IMAGE_TAG --parameters APPIMAGEARMTAG=$APP_IMAGE_ARM_TAG --parameters APPIMAGEAMDTAG=$APP_IMAGE_AMD_TAG
