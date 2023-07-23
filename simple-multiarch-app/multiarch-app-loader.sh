#!/bin/bash -x
cd /usr/src/app/
n=$NUM_OF_LOAD_THREADS
for ((i=1 ; i<=$n ; i++))
do
  ./call-simple-web-app.sh &
  ./call-simple-web-app.sh &
  sleep $SLEEP_BETWEEN_CYCLE
done
./call-simple-web-app.sh
