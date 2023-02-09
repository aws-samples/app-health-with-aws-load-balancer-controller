#!/bin/bash -x
n=$NUM_OF_LOAD_THREADS
for ((i=1 ; i<=$n ; i++))
do
  /order-update-from-sqs.sh &
  sleep $SLEEP_BETWEEN_CYCLE
done
/insert-order.sh 
