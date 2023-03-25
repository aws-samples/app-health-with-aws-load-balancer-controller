# Simple Web Application to demonstrate deployment of multi-arch images of ARM64 and AMD64

## Deploy steps
* Populate the following enviroment variables

```shell
export AWS_ACCOUNT_ID=$(aws sts get-caller-identity --output text --query Account)
export AWS_REGION=us-west-2
export BUILDX_VER=v0.10.3
export APP_IMAGE_NAME=simplemultiarchimage
export APP_IMAGE_TAG=multiarch-py3
export CLUSTER_NAME=grv-usw2
export KARPENTER_VERSION=v0.27.0
export AWS_DEFAULT_REGION=us-west-2
export TEMPOUT=$(mktemp)
```

* Enable multi-arch builds (linux/arm64 and linux/amd64)
```bash
docker buildx create --name craftbuilder
```

* Create and deploy the ECR docker registry and images for the app

```bash
./create-ecr-sqs.sh
./buildx.sh
```

* Deploy Karpenter
Follow https://karpenter.sh for cluster and karpneter install

* Deploy container insights
Follow [container insights deploy steps](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/Container-Insights-setup-EKS-quickstart.html)
```bash
ClusterName=${CLUSTER_NAME}
RegionName=${AWS_REGION}
FluentBitHttpPort='2020'
FluentBitReadFromHead='Off'
[[ ${FluentBitReadFromHead} = 'On' ]] && FluentBitReadFromTail='Off'|| FluentBitReadFromTail='On'
[[ -z ${FluentBitHttpPort} ]] && FluentBitHttpServer='Off' || FluentBitHttpServer='On'
curl https://raw.githubusercontent.com/aws-samples/amazon-cloudwatch-container-insights/latest/k8s-deployment-manifest-templates/deployment-mode/daemonset/container-insights-monitoring/quickstart/cwagent-fluent-bit-quickstart.yaml | sed 's/{{cluster_name}}/'${ClusterName}'/;s/{{region_name}}/'${RegionName}'/;s/{{http_server_toggle}}/"'${FluentBitHttpServer}'"/;s/{{http_server_port}}/"'${FluentBitHttpPort}'"/;s/{{read_from_head}}/"'${FluentBitReadFromHead}'"/;s/{{read_from_tail}}/"'${FluentBitReadFromTail}'"/' | kubectl apply -f -
```

* Deploy AWS LoadBalancer Controller
Follow [aws-loadbalancer-controllers](https://docs.aws.amazon.com/eks/latest/userguide/aws-load-balancer-controller.html)
```bash
eksctl create iamserviceaccount \
  --cluster=${CLUSTER_NAME} \
  --namespace=kube-system \
  --name=aws-load-balancer-controller \
  --role-name "AmazonEKSLoadBalancerControllerRole" \
  --attach-policy-arn=arn:aws:iam::${AWS_ACCOUNT_ID}:policy/AWSLoadBalancerControllerIAMPolicy \
  --approve

helm install aws-load-balancer-controller eks/aws-load-balancer-controller \
  -n kube-system \
  --set clusterName=${CLUSTER_NAME} \
  --set serviceAccount.create=false \
  --set serviceAccount.name=aws-load-balancer-controller
```

* Deploy karpenter provisioner

```bash
cat tlvsummit23-provisioner.yaml | envsubst | kubectl apply -f -
```

* Create K8s service and ingress for the sample webapp

```bash
cat app-svc-ingress.yaml | envsubst | kubectl apply -f -
```

* Deploy the sample app

```shell
cat app-deploy.yaml | envsubst | kubectl apply -f -
```

* Discover the ingress ALB endpoint

```shell
kubectl get ingress
```

Copy the ADDRESS value and browse to http://$ADDRESS/tlvsummit23/runtime/ and notice the `instance-type` alternating between pods that runs on `arm64` and `amd64` cpus.

TODO: ADD PERF ANALYSIS WITH CW CONTAINER INSIGHTS

```
kubectl autoscale deploy armsimplemultiarchapp --cpu-percent=90 --min=1 --max=100
kubectl autoscale deploy amdsimplemultiarchapp --cpu-percent=80 --min=1 --max=100
kubectl autoscale deploy amdsimplemultiarchproc --cpu-percent=80 --min=1 --max=100
kubectl autoscale deploy armsimplemultiarchproc --cpu-percent=90 --min=1 --max=100
```


### Processing nerrative
In this example, we generate two matrices of configurable sizes. We then define the number of processes to use (num_cores) and create a Pool of processes. Next, we create a list of row-column pairs to calculate by iterating over each row of the first matrix and each column of the second matrix. We then use the map method of the pool to apply the matrix_multiply function to each row-column pair in the list, resulting in a list of calculated values. Finally, we reshape the resulting list into a matrix of the appropriate size.

Note that using multiprocessing for matrix multiplication may not always result in a speedup, as the overhead of creating and managing the processes can sometimes outweigh the benefits of parallelism. It is always a good idea to benchmark different implementations and compare their performance.
