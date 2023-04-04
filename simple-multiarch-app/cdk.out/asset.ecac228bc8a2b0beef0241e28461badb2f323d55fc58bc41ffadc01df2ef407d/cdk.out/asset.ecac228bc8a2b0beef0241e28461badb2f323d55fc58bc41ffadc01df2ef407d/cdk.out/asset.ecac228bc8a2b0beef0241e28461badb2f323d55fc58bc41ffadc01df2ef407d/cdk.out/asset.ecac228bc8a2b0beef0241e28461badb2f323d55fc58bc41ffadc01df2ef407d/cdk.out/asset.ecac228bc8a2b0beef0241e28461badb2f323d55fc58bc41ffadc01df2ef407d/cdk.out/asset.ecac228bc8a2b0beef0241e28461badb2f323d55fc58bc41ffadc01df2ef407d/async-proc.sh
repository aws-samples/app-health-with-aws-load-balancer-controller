#!/bin/bash -x
n=$NUM_OF_LOAD_THREADS
for ((i=1 ; i<=$n ; i++))
do
  /usr/src/app/async-proc-thread.sh &
  sleep $SLEEP_BETWEEN_CYCLE
done
/usr/src/app/async-proc-thread.sh
