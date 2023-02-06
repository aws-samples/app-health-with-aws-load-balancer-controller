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

echo `date`
ret=`psql -P pager=off -w -c "select query from pg_stat_activity where query like 'vacuum freeze verbose%';"`
if (( $?>0 ))
then
  echo "ERR-PSQL"
  exit
fi
ret1=`echo $ret | grep vacuum`
echo $PGHOST
if [ "$ret1" ]
then
  echo $ret1" already running"
else
  psql -P pager=off -w -c "vacuum freeze verbose logistics_delivery;"&
  psql -P pager=off -w -c "vacuum freeze verbose logistics_order;"
fi
