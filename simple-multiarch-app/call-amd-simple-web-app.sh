#!/bin/bash -x

while true
do
  ret=`curl -o /dev/null -w '%{http_code}' -sL ${AMD_APP_URL}/runtime/`
  #if [ "$ret" != 200 ]; then
  #  aws cloudwatch put-metric-data --metric-name ${ret} --namespace ${DEPLOY_NAME} --value 1 --dimensions app="Intel"
  #fi
  sleep 1
  ret=`curl -o /dev/null -w '%{http_code}' -sL ${AMD_APP_URL}/runtime/`
  #if [ "$ret" != 200 ]; then
  #  aws cloudwatch put-metric-data --metric-name ${ret} --namespace ${DEPLOY_NAME} --value 1 --dimensions app="Intel"
  #fi
  sleep $SLEEP_BETWEEN_CYCLE
done
