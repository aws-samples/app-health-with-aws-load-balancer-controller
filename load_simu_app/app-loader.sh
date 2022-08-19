#!/bin/bash -x

while true
do
  ret=`curl -o /dev/null -w '%{http_code}' -sL ${APP_URL}/todaysorders/`
  aws cloudwatch put-metric-data --metric-name ${ret} --namespace ${DEPLOY_NAME} --value 1
  ret=`curl -o /dev/null -w '%{http_code}' -sL ${APP_URL}/neworder/`
  aws cloudwatch put-metric-data --metric-name ${ret} --namespace ${DEPLOY_NAME} --value 1
  sleep $SLEEP_BETWEEN_CYCLE
done
