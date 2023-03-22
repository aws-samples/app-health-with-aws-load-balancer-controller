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

while true
do
  ids=`psql -A -q -t -w -c "
begin;
/*insert series*/insert into logistics_order(uuid,created_at,updated_at,product,product_desc,customer_desc,origin,dest,manufacturer,order_group,purchase_order,required_by,unit,order_user,payment,bill_to,bill_address,customer_id,merchant_id) select uuid_generate_v4(),NOW(),NOW(),uuid_generate_v4(),uuid_generate_v4(),uuid_generate_v4(),uuid_generate_v4(),uuid_generate_v4(),uuid_generate_v4(),uuid_generate_v4(),uuid_generate_v4(),uuid_generate_v4(),uuid_generate_v4(),uuid_generate_v4(),uuid_generate_v4(),uuid_generate_v4(),uuid_generate_v4(),1,1 from generate_series(1,10) returning id;
/*insert series*/insert into logistics_delivery(product,product_desc,customer_desc,origin,manufacturer,required_by,bill_address,bill_to,payment,order_user,unit,purchase_order,order_group,dest,uuid,created_at,updated_at,method) select uuid_generate_v4(),uuid_generate_v4(),uuid_generate_v4(),uuid_generate_v4(),uuid_generate_v4(),uuid_generate_v4(),uuid_generate_v4(),uuid_generate_v4(),uuid_generate_v4(),uuid_generate_v4(),uuid_generate_v4(),uuid_generate_v4(),uuid_generate_v4(),uuid_generate_v4(),uuid_generate_v4(),NOW(),NOW(),md5(RANDOM()::TEXT) from generate_series(1,10) returning id;
commit;"`
  echo "psql exit code="$?
  if (( $?>0 ))
  then
    echo "ERR-DB"
#  else
#    aws sqs send-message --queue-url ${QUEUE_URL} --message-body "${id}" 
#    echo "sqs exit code="$?
  fi
  #sleep `awk -v min=10 -v max=30 'BEGIN{srand(); print int(min+rand()*(max-min+1))}'`
  sleep 5
done
