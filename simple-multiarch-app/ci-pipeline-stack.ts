#!/usr/bin/env node

import { Stack, StackProps,CfnParameter,SecretValue} from 'aws-cdk-lib';
import { Construct } from 'constructs'
import * as codecommit from 'aws-cdk-lib/aws-codecommit';
import * as ecr from 'aws-cdk-lib/aws-ecr';
import * as codebuild from 'aws-cdk-lib/aws-codebuild';
import * as codepipeline from 'aws-cdk-lib/aws-codepipeline';
import * as codepipeline_actions from 'aws-cdk-lib/aws-codepipeline-actions';
import * as iam from "aws-cdk-lib/aws-iam";
import * as sm from "aws-cdk-lib/aws-secretsmanager";
import console = require('console');

export class AppPipelineStack extends Stack {
  constructor(scope: Construct, id: string, props?: StackProps) {
    super(scope, id, props);
  const BUILDX_VER = new CfnParameter(this,"BUILDXVER",{type:"String"});
  const APP_IMAGE_NAME = new CfnParameter(this,"APPIMAGENAME",{type:"String"});
  const APP_IMAGE_TAG = new CfnParameter(this,"APPIMAGETAG",{type:"String"});
  const APP_IMAGE_AMD_TAG = new CfnParameter(this,"APPIMAGEAMDTAG",{type:"String"});
  const APP_IMAGE_ARM_TAG = new CfnParameter(this,"APPIMAGEARMTAG",{type:"String"});
  const GITHUB_OAUTH_TOKEN = new CfnParameter(this,"GITHUBOAUTHTOKEN",{type:"String"});
  const GITHUB_USER = new CfnParameter(this,"GITHUBUSER",{type:"String"});
  const GITHUB_REPO = new CfnParameter(this,"GITHUBREPO",{type:"String"});
  const GITHUB_BRANCH = new CfnParameter(this,"GITHUBBRANCH",{type:"String"});
 
  /* 
  const secret = sm.Secret.fromSecretAttributes(this,'ImportedSecret',{
    secretCompleteArn:
      "arn:aws:secretsmanager:us-west-2:907513986313:secret:lyra-github-token-BMUCM4"
  });*/
  
  
  //codecommit repository that will contain the containerized app to build
  /*const app_gitrepo = new codecommit.Repository(this, `app_gitrepo`, {
    repositoryName:APP_IMAGE_NAME.valueAsString,
    description: "Git repository for the pipeline, includes all the build phases",
    code: codecommit.Code.fromDirectory('./','main'),
  });*/
  const app_gitrepo = codecommit.Repository.fromRepositoryName(this,`gitrepo`,APP_IMAGE_NAME.valueAsString)
    
  /*const app_registry = new ecr.Repository(this,`app_registry`,{
    repositoryName:APP_IMAGE_NAME.valueAsString,
    imageScanOnPush: true
  });*/
  const app_registry = ecr.Repository.fromRepositoryName(this,`app_registry`,APP_IMAGE_NAME.valueAsString)

  //create a roleARN for codebuild 
  const buildRole = new iam.Role(this, 'AppCodeBuildDeployRole',{
    roleName: process.env.AWS_REGION+"AppCodeBuildDeployRole",
    assumedBy: new iam.ServicePrincipal('codebuild.amazonaws.com'),
  });
  
  buildRole.addToPolicy(new iam.PolicyStatement({
    resources: ['*'],
    actions: ['ssm:PutParameter'],
  }));
    
  const app_image_buildx = new codebuild.Project(this, `AppImageBuild`, {
    environment: {privileged:true,buildImage: codebuild.LinuxBuildImage.AMAZON_LINUX_2_ARM_2},
    cache: codebuild.Cache.local(codebuild.LocalCacheMode.DOCKER_LAYER, codebuild.LocalCacheMode.CUSTOM),
    role: buildRole,
    buildSpec: codebuild.BuildSpec.fromObject(
      {
        version: "0.2",
        env: {
          'exported-variables': [
            'AWS_ACCOUNT_ID','AWS_REGION','APP_IMAGE_NAME','APP_IMAGE_TAG','BUILDX_VER'
          ],
        },
        phases: {
          build: {
            commands: [
              `chmod +x ./enable-buildx.sh && ./enable-buildx.sh`,
              `export AWS_ACCOUNT_ID="${this.account}"`,
              `export AWS_REGION="${this.region}"`,
              `export APP_IMAGE_NAME="${APP_IMAGE_NAME.valueAsString}"`,
              `export BUILDX_VER="${BUILDX_VER.valueAsString}"`,
              `export APP_IMAGE_TAG="${APP_IMAGE_TAG.valueAsString}"`,
              `chmod +x ./buildx.sh && ./buildx.sh`
            ],
          }
        },
        artifacts: {
          files: ['imageDetail.json']
        },
      }
    ),
  });


  const app_image_arm_build = new codebuild.Project(this, `AppImageArmBuild`, {
    environment: {privileged:true,buildImage: codebuild.LinuxBuildImage.AMAZON_LINUX_2_ARM_2},
    cache: codebuild.Cache.local(codebuild.LocalCacheMode.DOCKER_LAYER, codebuild.LocalCacheMode.CUSTOM),
    role: buildRole,
    buildSpec: codebuild.BuildSpec.fromObject(
      {
        version: "0.2",
        env: {
          'exported-variables': [
            'AWS_ACCOUNT_ID','AWS_REGION','APP_IMAGE_NAME','APP_IMAGE_TAG'
          ],
        },
        phases: {
          build: {
            commands: [
              `export AWS_ACCOUNT_ID="${this.account}"`,
              `export AWS_REGION="${this.region}"`,
              `export APP_IMAGE_NAME="${APP_IMAGE_NAME.valueAsString}"`,
              `export APP_IMAGE_TAG="${APP_IMAGE_ARM_TAG.valueAsString}"`,
              `chmod +x ./simple-multiarch-app/build.sh && ./simple-multiarch-app/build.sh`
            ],
          }
        },
        artifacts: {
          files: ['imageDetail.json']
        },
      }
    ),
  });

  const app_image_amd_build = new codebuild.Project(this, `AppImageAmdBuild`, {
    environment: {privileged:true,buildImage: codebuild.LinuxBuildImage.AMAZON_LINUX_2_3},
    cache: codebuild.Cache.local(codebuild.LocalCacheMode.DOCKER_LAYER, codebuild.LocalCacheMode.CUSTOM),
    role: buildRole,
    buildSpec: codebuild.BuildSpec.fromObject(
      {
        version: "0.2",
        env: {
          'exported-variables': [
            'AWS_ACCOUNT_ID','AWS_REGION','APP_IMAGE_NAME','APP_IMAGE_TAG'
          ],
        },
        phases: {
          build: {
            commands: [
              `export AWS_ACCOUNT_ID="${this.account}"`,
              `export AWS_REGION="${this.region}"`,
              `export APP_IMAGE_NAME="${APP_IMAGE_NAME.valueAsString}"`,
              `export APP_IMAGE_TAG="${APP_IMAGE_AMD_TAG.valueAsString}"`,
              `chmod +x ./simple-multiarch-app/build.sh && ./simple-multiarch-app/build.sh`
            ],
          }
        },
        artifacts: {
          files: ['imageDetail.json']
        },
      }
    ),
  });

  const app_image_assembly = new codebuild.Project(this, `AppImageAmdBuildAssembly`, {
    environment: {privileged:true,buildImage: codebuild.LinuxBuildImage.AMAZON_LINUX_2_ARM_2},
    cache: codebuild.Cache.local(codebuild.LocalCacheMode.DOCKER_LAYER, codebuild.LocalCacheMode.CUSTOM),
    role: buildRole,
    buildSpec: codebuild.BuildSpec.fromObject(
      {
        version: "0.2",
        env: {
          'exported-variables': [
            'AWS_ACCOUNT_ID','AWS_REGION','APP_IMAGE_NAME','APP_IMAGE_AMD_TAG','APP_IMAGE_ARM_TAG','APP_IMAGE_TAG'
          ],
        },
        phases: {
          build: {
            commands: [
              `export AWS_ACCOUNT_ID="${this.account}"`,
              `export AWS_REGION="${this.region}"`,
              `export APP_IMAGE_NAME="${APP_IMAGE_NAME.valueAsString}"`,
              `export APP_IMAGE_AMD_TAG="${APP_IMAGE_AMD_TAG.valueAsString}"`,
              `export APP_IMAGE_ARM_TAG="${APP_IMAGE_ARM_TAG.valueAsString}"`,
              `export APP_IMAGE_TAG="${APP_IMAGE_TAG.valueAsString}"`,
              `chmod +x ./simple-multiarch-app/assemble_multiarch_image.sh && ./simple-multiarch-app/assemble_multiarch_image.sh`
            ],
          }
        },
        artifacts: {
          files: ['imageDetail.json']
        },
      }
    ),
  });
    
  //we allow the buildProject principal to push images to ecr
  app_registry.grantPullPush(app_image_buildx.grantPrincipal);
  app_registry.grantPullPush(app_image_arm_build.grantPrincipal);
  app_registry.grantPullPush(app_image_amd_build.grantPrincipal);
  app_registry.grantPullPush(app_image_assembly.grantPrincipal);

  // here we define our pipeline and put together the assembly line
  const sourceOutput = new codepipeline.Artifact();

  const appbuildpipeline = new codepipeline.Pipeline(this,`AppBasePipeline`);
  /*appbuildpipeline.addStage({
    stageName: 'CodeCommitSource',
    actions: [
      new codepipeline_actions.CodeCommitSourceAction({
        actionName: 'CodeCommit_Source',
        repository: app_gitrepo,
        output: sourceOutput,
        branch: 'main'
      })
      ]
  });*/
  
  appbuildpipeline.addStage({
    stageName: 'gitHubSource',
    actions: [
      new codepipeline_actions.GitHubSourceAction({
        actionName: 'gitHub_Source',
        owner: GITHUB_USER.valueAsString,
        repo: GITHUB_REPO.valueAsString,
        branch: GITHUB_BRANCH.valueAsString,
        output: sourceOutput,
        oauthToken: SecretValue.unsafePlainText(GITHUB_OAUTH_TOKEN.valueAsString)
        //oauthToken: secret.secretValue
      })
      ]
  }); 
 
  appbuildpipeline.addStage({
    stageName: 'AppImageBuild',
    actions: [
      new codepipeline_actions.CodeBuildAction({
        actionName: 'AppImageArmBuild',
        input: sourceOutput,
        runOrder: 1,
        project: app_image_arm_build
      }),
      new codepipeline_actions.CodeBuildAction({
        actionName: 'AppImageAmdBuild',
        input: sourceOutput,
        runOrder: 1,
        project: app_image_amd_build
      }),
      new codepipeline_actions.CodeBuildAction({
          actionName: 'AssembleAppBuilds',
          input: sourceOutput,
          runOrder: 2,
          project: app_image_assembly
        })
    ]
  });
  }
}
