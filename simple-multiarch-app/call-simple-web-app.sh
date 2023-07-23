#!/bin/bash
while true
do
  cmd="curl -o /dev/null -sL ${APP_URL}/runtime/" 
  http_response_time=`TIMEFORMAT="%R"; { time $cmd; } 2>&1`
  aws cloudwatch put-metric-data --metric-name http_response_time --namespace ${DEPLOY_NAME} --value $http_response_time
  sleep $SLEEP_BETWEEN_CYCLE
done
