#!/usr/bin/env node
import 'source-map-support/register';
import * as cdk from 'aws-cdk-lib';
import { AppPipelineStack } from './ci-pipeline-stack';

const app = new cdk.App();
new AppPipelineStack(app, 'AppPipelineStack', {
  env: { account: process.env.AWS_ACCOUNT_ID, region: process.env.AWS_REGION},
});
