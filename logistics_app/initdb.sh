#!/bin/bash -x

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

#psql -c "create extension \"uuid-ossp\";"

sed -i "s/PGUSER/$PGUSER/g" django_app/settings.py 
sed -i "s/PGDATABASE/$PGDATABASE/g" django_app/settings.py
sed -i "s/PGPASSWORD/$PGPASSWORD/g" django_app/settings.py
sed -i "s/PGHOST/$PGHOST/g" django_app/settings.py
sed -i "s/PGPORT/$PGPORT/g" django_app/settings.py

./manage.py pgmakemigrations
./manage.py migrate 
#psql -c "drop table logistics_order_default;"
#psql -c "drop table logistics_delivery_default;"
#psql -c "delete from partman.part_config;"
#psql -c "CREATE SCHEMA partman;CREATE EXTENSION pg_partman WITH SCHEMA partman;CREATE EXTENSION pg_cron;"
#psql -c "SELECT partman.create_parent( p_parent_table => 'public.logistics_order',p_control => 'created_at',p_type => 'native',p_interval=> 'weekly',p_premake => 4);"
#psql -c "SELECT partman.create_parent( p_parent_table => 'public.logistics_delivery',p_control => 'created_at',p_type => 'native',p_interval=> 'weekly',p_premake => 4);"
#psql -c "insert into logistics_customer(uuid,first_name,last_name,address) select uuid_generate_v4(),md5(RANDOM()::TEXT),md5(RANDOM()::TEXT),md5(RANDOM()::TEXT) from generate_series(1,100);"
#psql -c "insert into logistics_merchant(uuid,name,address,license) select uuid_generate_v4(),md5(RANDOM()::TEXT),md5(RANDOM()::TEXT),md5(RANDOM()::TEXT) from generate_series(1,100);"
#psql -c "insert into logistics_order(order_group,purchase_order,required_by,unit,order_user,payment,bill_to,bill_address,customer_desc,dest,manufacturer,origin,product_desc,uuid,created_at,updated_at,product,customer_id,merchant_id) select uuid_generate_v4(),uuid_generate_v4(),uuid_generate_v4(),uuid_generate_v4(),uuid_generate_v4(),uuid_generate_v4(),uuid_generate_v4(),uuid_generate_v4(),uuid_generate_v4(),uuid_generate_v4(),uuid_generate_v4(),uuid_generate_v4(),uuid_generate_v4(),uuid_generate_v4(),NOW(),NOW(),uuid_generate_v4(),*,* from generate_series(1,99);"
#psql -c "insert into logistics_delivery(uuid,created_at,updated_at,method,order_id) select uuid_generate_v4(),NOW(),NOW(),md5(RANDOM()::TEXT),* from generate_series(1,99);"
#psql -c "insert into logistics_delivery(product,product_desc,customer_desc,origin,manufacturer,required_by,bill_address,bill_to,payment,order_user,unit,purchase_order,order_group,dest,uuid,created_at,updated_at,method) select uuid_generate_v4(),uuid_generate_v4(),uuid_generate_v4(),uuid_generate_v4(),uuid_generate_v4(),uuid_generate_v4(),uuid_generate_v4(),uuid_generate_v4(),uuid_generate_v4(),uuid_generate_v4(),uuid_generate_v4(),uuid_generate_v4(),uuid_generate_v4(),uuid_generate_v4(),uuid_generate_v4(),NOW(),NOW(),md5(RANDOM()::TEXT) from generate_series(1,99);"
#psql -c "UPDATE partman.part_config SET infinite_time_partitions = true,retention = '3 years',retention_keep_table=true WHERE parent_table = 'public.logistics_order';"
#psql -c "UPDATE partman.part_config SET infinite_time_partitions = true,retention = '3 years',retention_keep_table=true WHERE parent_table = 'public.logistics_delivery';"
#psql -c "SELECT cron.schedule('@daily', \$\$CALL partman.run_maintenance_proc()\$\$);"
