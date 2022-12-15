EKS_CLUSTER_NAME=lb-health-x86
AWS_REGION=us-west-2
SERVICE="rds"
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query "Account" --output text)
OIDC_PROVIDER=$(aws eks describe-cluster --name $EKS_CLUSTER_NAME --region $AWS_REGION --query "cluster.identity.oidc.issuer" --output text | sed -e "s/^https:\/\///")
ACK_K8S_NAMESPACE=ack-system

ACK_K8S_SERVICE_ACCOUNT_NAME=ack-$SERVICE-controller

ACK_CONTROLLER_IAM_ROLE="ack-${SERVICE}-controller"
ACK_CONTROLLER_IAM_ROLE_DESCRIPTION="IRSA role for ACK ${SERVICE} controller deployment on EKS cluster using Helm charts"
aws iam create-role --role-name "${ACK_CONTROLLER_IAM_ROLE}" --assume-role-policy-document file://trust.json --description "${ACK_CONTROLLER_IAM_ROLE_DESCRIPTION}"
ACK_CONTROLLER_IAM_ROLE_ARN=$(aws iam get-role --role-name=$ACK_CONTROLLER_IAM_ROLE --query Role.Arn --output text)


BASE_URL=https://raw.githubusercontent.com/aws-controllers-k8s/${SERVICE}-controller/main
POLICY_ARN_URL=${BASE_URL}/config/iam/recommended-policy-arn
POLICY_ARN_STRINGS="$(wget -qO- ${POLICY_ARN_URL})"

INLINE_POLICY_URL=${BASE_URL}/config/iam/recommended-inline-policy
INLINE_POLICY="$(wget -qO- ${INLINE_POLICY_URL})"

while IFS= read -r POLICY_ARN; do
	    echo -n "Attaching $POLICY_ARN ... "
	        aws iam attach-role-policy \
			        --role-name "${ACK_CONTROLLER_IAM_ROLE}" \
				        --policy-arn "${POLICY_ARN}"
		    echo "ok."
	    done <<< "$POLICY_ARN_STRINGS"

	    if [ ! -z "$INLINE_POLICY" ]; then
		        echo -n "Putting inline policy ... "
			    aws iam put-role-policy \
				            --role-name "${ACK_CONTROLLER_IAM_ROLE}" \
					            --policy-name "ack-recommended-policy" \
						            --policy-document "$INLINE_POLICY"
			        echo "ok."
	    fi
SERVICE="rds"
ACK_K8S_SERVICE_ACCOUNT_NAME=ack-$SERVICE-controller
ACK_K8S_NAMESPACE=ack-system

ACK_CONTROLLER_IAM_ROLE="ack-${SERVICE}-controller"

ACK_CONTROLLER_IAM_ROLE_ARN=$(aws iam get-role --role-name=$ACK_CONTROLLER_IAM_ROLE --query Role.Arn --output text)


# Annotate the service account with the ARN
export IRSA_ROLE_ARN=eks.amazonaws.com/role-arn=$ACK_CONTROLLER_IAM_ROLE_ARN
kubectl annotate serviceaccount -n $ACK_K8S_NAMESPACE $ACK_K8S_SERVICE_ACCOUNT_NAME $IRSA_ROLE_ARN
SERVICE=rds
RELEASE_VERSION=$(curl -sL "https://api.github.com/repos/aws-controllers-k8s/${SERVICE}-controller/releases/latest" | grep '"tag_name":' | cut -d'"' -f4)
ACK_SYSTEM_NAMESPACE=ack-system
AWS_REGION=us-west-2
APP_NAMESPACE=default

# EKS_VPC_ID=$(aws eks describe-cluster --name "${EKS_CLUSTER_NAME}" --query "cluster.resourcesVpcConfig.vpcId" --output text)
EKS_VPC_ID="0.0.0.0/0"

RDS_SUBNET_GROUP_NAME="app-health-simu"
RDS_SUBNET_GROUP_DESCRIPTION="database subnet group for app load simulation"
EKS_SUBNET_IDS=$(aws ec2 describe-subnets --filter "Name=vpc-id,Values=${EKS_VPC_ID}" --query 'Subnets[?MapPublicIpOnLaunch==`false`].SubnetId' --output text)

cat <<-EOF > db-subnet-groups.yaml
apiVersion: rds.services.k8s.aws/v1alpha1
kind: DBSubnetGroup
metadata:
 name: ${RDS_SUBNET_GROUP_NAME}
 namespace: ${APP_NAMESPACE}
spec:
 name: ${RDS_SUBNET_GROUP_NAME}
 description: ${RDS_SUBNET_GROUP_DESCRIPTION}
 subnetIDs:
$(printf " - %s\n" ${EKS_SUBNET_IDS})
 tags: []
EOF

kubectl apply -f db-subnet-groups.yaml

RDS_SECURITY_GROUP_NAME="ack-security-group"
RDS_SECURITY_GROUP_DESCRIPTION="ACK security group"

EKS_CIDR_RANGE=$(aws ec2 describe-vpcs \
	 --vpc-ids "${EKS_VPC_ID}" \
	  --query "Vpcs[].CidrBlock" \
	   --output text
   )

   RDS_SECURITY_GROUP_ID=$(aws ec2 create-security-group \
	    --group-name "${RDS_SECURITY_GROUP_NAME}" \
	     --description "${RDS_SECURITY_GROUP_DESCRIPTION}" \
	      --vpc-id "${EKS_VPC_ID}" \
	       --output text
       )
       aws ec2 authorize-security-group-ingress \
	        --group-id "${RDS_SECURITY_GROUP_ID}" \
		 --protocol tcp \
		  --port 5432 \
		   --cidr "${EKS_CIDR_RANGE}"


RDS_DB_USERNAME=postgres
RDS_DB_PASSWORD="cs0PMNP1dXwr-8rh4oEcpXe=215asD"

kubectl create secret generic -n "${APP_NAMESPACE}" ack-creds \
	  --from-literal=username="${RDS_DB_USERNAME}" \
	    --from-literal=password="${RDS_DB_PASSWORD}"

export AURORA_DB_CLUSTER_NAME="ack-db"
export AURORA_DB_INSTANCE_NAME="ack-db-instance01"
export AURORA_DB_INSTANCE_CLASS="db.serverless"
export MAX_ACU=64
export MIN_ACU=4

export ENGINE_TYPE=aurora-postgresql
export ENGINE_VERSION=13
export RDS_SUBNET_GROUP_NAME="app-health-simu"
export APP_NAMESPACE=default

cat <<-EOF > asv2-db-cluster.yaml
apiVersion: rds.services.k8s.aws/v1alpha1
kind: DBCluster
metadata:
  name: ${AURORA_DB_CLUSTER_NAME}
  namespace: ${APP_NAMESPACE}
spec:
  backupRetentionPeriod: 7
  serverlessV2ScalingConfiguration:
    maxCapacity: ${MAX_ACU}
    minCapacity: ${MIN_ACU}
  dbClusterIdentifier: ${AURORA_DB_CLUSTER_NAME}
  dbSubnetGroupName: ${RDS_SUBNET_GROUP_NAME}
  engine: ${ENGINE_TYPE}
  engineVersion: "${ENGINE_VERSION}"
  masterUsername: postgres
  masterUserPassword:
    namespace: ${APP_NAMESPACE}
    name: ack-creds
    key: password
  vpcSecurityGroupIDs:
     - ${RDS_SECURITY_GROUP_ID}
EOF

kubectl apply -f asv2-db-cluster.yaml


cat <<-EOF > asv2-db-instance.yaml
apiVersion: rds.services.k8s.aws/v1alpha1
kind: DBInstance
metadata:
  name: ${AURORA_DB_INSTANCE_NAME}
  namespace: ${APP_NAMESPACE}
spec:
  dbInstanceClass: ${AURORA_DB_INSTANCE_CLASS}
  dbInstanceIdentifier: ${AURORA_DB_INSTANCE_NAME}
  dbClusterIdentifier: ${AURORA_DB_CLUSTER_NAME}
  dbSubnetGroupName: ${RDS_SUBNET_GROUP_NAME}
  engine: ${ENGINE_TYPE}
  engineVersion: "${ENGINE_VERSION}"
  publiclyAccessible: true
EOF

kubectl apply -f asv2-db-instance.yaml

