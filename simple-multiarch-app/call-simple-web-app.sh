#!/bin/bash -x
TIMEFORMAT=' %R'
while true
do
  app_ret=`time curl -o /dev/null -w '%{http_code}' -sL ${APP_URL}/runtime/` 
  http_code=`echo $app_ret| awk '{print $1}'`
  http_response_time=`echo $app_ret| awk '{print $2}'`
  if [ "$http_code" == 200 ]; then
    aws cloudwatch put-metric-data --metric-name http_response_time --namespace ${DEPLOY_NAME} --value $http_response_time
  fi
  sleep $SLEEP_BETWEEN_CYCLE
done
