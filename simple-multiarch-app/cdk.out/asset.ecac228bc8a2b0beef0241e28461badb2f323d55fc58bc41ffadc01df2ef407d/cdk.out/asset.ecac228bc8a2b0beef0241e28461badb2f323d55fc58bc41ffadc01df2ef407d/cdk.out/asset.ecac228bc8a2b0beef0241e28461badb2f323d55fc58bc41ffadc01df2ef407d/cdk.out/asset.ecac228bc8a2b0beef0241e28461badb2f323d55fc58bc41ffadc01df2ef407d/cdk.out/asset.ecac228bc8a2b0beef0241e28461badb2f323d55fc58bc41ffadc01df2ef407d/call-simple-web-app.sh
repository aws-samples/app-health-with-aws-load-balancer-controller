#!/bin/bash -x

while true
do
  ret=`curl -o /dev/null -w '%{http_code}' -sL ${ARM_APP_URL}/runtime/` &
  ret=`curl -o /dev/null -w '%{http_code}' -sL ${AMD_APP_URL}/runtime/`
  sleep $SLEEP_BETWEEN_CYCLE
done