#!/bin/bash


node_name=$(kubectl --namespace ${NAMESPACE} get pod ${POD_NAME} --output jsonpath="{.spec.nodeName}")
echo node_name=${node_name}

while true; do
  while [[ $(kubectl get no $node_name -o yaml | grep unschedulable: | awk '{print $2}') != "true" ]]; do
    echo $(date): ${node_status}
    sleep ${POLL_INTERVAL}
  done
  echo $(date): "node is cordoned"
  aws cloudwatch put-metric-data --metric-name node_cordoned --namespace ${CW_NAMESPACE} --value 1
done
