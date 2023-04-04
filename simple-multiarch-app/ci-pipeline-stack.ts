import { Stack, StackProps, CfnParameter  } from 'aws-cdk-lib';
import { Construct } from 'constructs'
import * as codecommit from 'aws-cdk-lib/aws-codecommit';
import * as ecr from 'aws-cdk-lib/aws-ecr';
import * as codebuild from 'aws-cdk-lib/aws-codebuild';
import * as codepipeline from 'aws-cdk-lib/aws-codepipeline';
import * as codepipeline_actions from 'aws-cdk-lib/aws-codepipeline-actions';
import * as iam from "aws-cdk-lib/aws-iam";

export class AppPipelineStack extends Stack {
  constructor(scope: Construct, id: string, props?: StackProps) {
    super(scope, id, props);
  const BUILDX_VER = new CfnParameter(this,"BUILDXVER",{type:"String"});
  const APP_IMAGE_NAME = new CfnParameter(this,"APPIMAGENAME",{type:"String"});
  const APP_IMAGE_TAG = new CfnParameter(this,"APPIMAGETAG",{type:"String"});
  const APP_IMAGE_AMD_TAG = new CfnParameter(this,"APPIMAGEAMDTAG",{type:"String"});
  const APP_IMAGE_ARM_TAG = new CfnParameter(this,"APPIMAGEARMTAG",{type:"String"});

  
  //codecommit repository that will contain the containerized app to build
  const app_gitrepo = new codecommit.Repository(this, `app_gitrepo`, {
    repositoryName:APP_IMAGE_NAME.valueAsString,
    description: "Git repository for the pipeline, includes all the build phases",
    code: codecommit.Code.fromDirectory('./','main'),
  });
  //const gitrepo = codecommit.Repository.fromRepositoryName(this,`gitrepo`,CODE_COMMIT_REPO.valueAsString)
    
  const app_registry = new ecr.Repository(this,`app_registry`,{
    repositoryName:APP_IMAGE_NAME.valueAsString,
    imageScanOnPush: true
  });
  //const base_registry = ecr.Repository.fromRepositoryName(this,`base_repo`,BASE_REPO.valueAsString)

  //create a roleARN for codebuild 
  const buildRole = new iam.Role(this, 'AppCodeBuildDeployRole',{
    roleName: "AppCodeBuildDeployRole",
    assumedBy: new iam.ServicePrincipal('codebuild.amazonaws.com'),
  });
  
  buildRole.addToPolicy(new iam.PolicyStatement({
    resources: ['*'],
    actions: ['ssm:*'],
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
            'AWS_ACCOUNT_ID','AWS_REGION','APP_IMAGE_NAME','APP_IMAGE_ARM_TAG'
          ],
        },
        phases: {
          build: {
            commands: [
              `export AWS_ACCOUNT_ID="${this.account}"`,
              `export AWS_REGION="${this.region}"`,
              `export APP_IMAGE_NAME="${APP_IMAGE_NAME.valueAsString}"`,
              `export APP_IMAGE_ARM_TAG="${APP_IMAGE_ARM_TAG.valueAsString}"`,
              `chmod +x ./build.sh && ./build.sh`
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
            'AWS_ACCOUNT_ID','AWS_REGION','APP_IMAGE_NAME','APP_IMAGE_AMD_TAG'
          ],
        },
        phases: {
          build: {
            commands: [
              `export AWS_ACCOUNT_ID="${this.account}"`,
              `export AWS_REGION="${this.region}"`,
              `export APP_IMAGE_NAME="${APP_IMAGE_NAME.valueAsString}"`,
              `export APP_IMAGE_AMD_TAG="${APP_IMAGE_AMD_TAG.valueAsString}"`,
              `chmod +x ./build.sh && ./build.sh`
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
              `chmod +x ./assemble_multiarch_image.sh && ./assemble_multiarch_image.sh`
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
  const sourceOuput = new codepipeline.Artifact();

  const appbuildpipeline = new codepipeline.Pipeline(this,`AppBasePipeline`);
  appbuildpipeline.addStage({
    stageName: 'Source',
    actions: [
      new codepipeline_actions.CodeCommitSourceAction({
        actionName: 'CodeCommit_Source',
        repository: app_gitrepo,
        output: sourceOuput,
        branch: 'main'
      })
      ]
  });

  appbuildpipeline.addStage({
    stageName: 'AppImageBuild',
    actions: [
      new codepipeline_actions.CodeBuildAction({
        actionName: 'AppImageArmBuild',
        input: sourceOuput,
        runOrder: 1,
        project: app_image_arm_build
      }),
      new codepipeline_actions.CodeBuildAction({
        actionName: 'AppImageAmdBuild',
        input: sourceOuput,
        runOrder: 1,
        project: app_image_amd_build
      }),
      new codepipeline_actions.CodeBuildAction({
          actionName: 'AssembleAppBuilds',
          input: sourceOuput,
          runOrder: 2,
          project: app_image_assembly
        })
    ]
  });
  /*const appbuildxpipeline = new codepipeline.Pipeline(this,`BuildXAppPipeline`);
  appbuildxpipeline.addStage({
    stageName: 'Source',
    actions: [
      new codepipeline_actions.CodeCommitSourceAction({
        actionName: 'CodeCommit_Source',
        repository: app_gitrepo,
        output: sourceOuput,
        branch: 'main'
      })
      ]
  });
  appbuildxpipeline.addStage({
    stageName: 'AppImageBuildX',
    actions: [
       new codepipeline_actions.CodeBuildAction({
         actionName: 'Build_Code',
         input: sourceOuput,
         project: app_image_buildx
       }),
       ]
  });*/
  }
}
