#!/bin/bash -x
n=$NUM_OF_LOAD_THREADS
for ((i=1 ; i<=$n ; i++))
do
  /call-logistics-app.sh &
  sleep $SLEEP_BETWEEN_CYCLE
done
/call-logistics-app.sh
