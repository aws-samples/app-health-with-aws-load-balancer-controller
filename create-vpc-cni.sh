eksctl create iamserviceaccount \
    --name aws-node \
    --namespace kube-system \
    --cluster lb-health-us-west-2 \
    --role-name "AmazonEKSVPCCNIRole" \
    --attach-policy-arn arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy \
    --override-existing-serviceaccounts \
    --approve



eksctl create addon \
    --name vpc-cni \
    --version v1.11.2-eksbuild.1 \
    --cluster lb-health-us-west-2 \
    --service-account-role-arn arn:aws:iam::604429864555:role/AmazonEKSVPCCNIRole \
    --force
