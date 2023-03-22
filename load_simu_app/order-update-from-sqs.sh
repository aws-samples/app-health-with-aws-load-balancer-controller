#!/bin/bash

PGUSER=`cat $SECRET_FILE | jq -r '.username'`
PGDATABASE=`cat $SECRET_FILE | jq -r '.username'`
PGPASSWORD=`cat $SECRET_FILE | jq -r '.password'`
PGHOST=`cat $SECRET_FILE | jq -r '.host'`
PGPORT=`cat $SECRET_FILE | jq -r '.port'`

export PGUSER=$PGUSER
export PGDATABASE=$PGDATABASE
export PGPASSWORD=$PGPASSWORD
export PGHOST=$PGHOST
export PGPORT=$PGPORT

sqs_file="/tmp/"$RANDOM".json"
while true
do
  aws sqs receive-message --queue-url ${ORDER_QUEUE}  > $sqs_file
  echo "sqs exit code="$?
  if (( $?>0 )) 
  then
    echo "ERR-SQS"
    continue
  fi
  receipt_handle=`cat $sqs_file | jq '.Messages[].ReceiptHandle'|sed 's/"//g'`
  ret_val=`cat $sqs_file | jq '.Messages[].Body'|sed 's/"//g'`
  id=`echo $ret_val | awk -F\| '{print $1}'`
  if [ -z "$id" ]
  then
    echo "EMPTY-SQS"
    continue
  else
    max_id=`echo $(($id+10))`
    psql -A -e -t -w -c "
begin;
/*update from sqs*/update logistics_order set updated_at=NOW() where id >= "$id" and id < $max_id;
commit;"
    logistics_delivery_ids=`psql -A -q -t -w -c "
insert into logistics_delivery(order_id,product,product_desc,customer_desc,origin,manufacturer,required_by,bill_address,bill_to,payment,order_user,unit,purchase_order,order_group,dest,uuid,created_at,updated_at,method) select $id,uuid_generate_v4(),uuid_generate_v4(),uuid_generate_v4(),uuid_generate_v4(),uuid_generate_v4(),uuid_generate_v4(),uuid_generate_v4(),uuid_generate_v4(),uuid_generate_v4(),uuid_generate_v4(),uuid_generate_v4(),uuid_generate_v4(),uuid_generate_v4(),uuid_generate_v4(),uuid_generate_v4(),NOW(),NOW(),md5(RANDOM()::TEXT) from generate_series(1,10) returning id;
    "`
    echo "logistics_delivery_ids:"$logistics_delivery_ids
    delivery_id=`psql -A -q -t -w -c "
insert into logistics_delivery(order_id,product,product_desc,customer_desc,origin,manufacturer,required_by,bill_address,bill_to,payment,order_user,unit,purchase_order,order_group,dest,uuid,created_at,updated_at,method) select $id,uuid_generate_v4(),uuid_generate_v4(),uuid_generate_v4(),uuid_generate_v4(),uuid_generate_v4(),uuid_generate_v4(),uuid_generate_v4(),uuid_generate_v4(),uuid_generate_v4(),uuid_generate_v4(),uuid_generate_v4(),uuid_generate_v4(),uuid_generate_v4(),uuid_generate_v4(),uuid_generate_v4(),NOW(),NOW(),md5(RANDOM()::TEXT) from generate_series(1,1) returning id;
    "`
    aws sqs send-message --queue-url ${DELIVERY_QUEUE} --message-body "${delivery_id}"
    echo "psql exit code="$?
    if (( $?>0 )) 
    then
      echo "ERR-DB"
      sleep 5
    fi
  fi
done
