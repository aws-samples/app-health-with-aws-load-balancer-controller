#!/bin/bash -x

sqs_file="/tmp/"$RANDOM".json"

while true
do
  aws sqs receive-message --queue-url ${APP_QUEUE}  > $sqs_file
  echo "sqs exit code="$?
  if (( $?>0 ))
  then
    echo "ERR-SQS"
    continue
  fi
  receipt_handle=`cat $sqs_file | jq '.Messages[].ReceiptHandle'|sed 's/"//g'`
  ret_val=`cat $sqs_file | jq '.Messages[].Body'|sed 's/"//g'`
  uuid=`echo $ret_val | awk -F\| '{print $1}'`
  if [ -z "$uuid" ]
  then
    echo "EMPTY-SQS"
    continue
  else
    /usr/src/app/do_multiprocessing.py
  fi
  aws sqs delete-message --queue-url ${APP_QUEUE} --receipt-handle $receipt_handle
done
