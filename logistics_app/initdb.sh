#!/bin/bash


sed -i "s/PGUSER/$PGUSER/g" django_app/settings.py 
sed -i "s/PGDATABASE/$PGDATABASE/g" django_app/settings.py
sed -i "s/PGPASSWORD/$PGPASSWORD/g" django_app/settings.py
sed -i "s/PGHOST/$PGHOST/g" django_app/settings.py
sed -i "s/PGPORT/$PGPORT/g" django_app/settings.py

./manage.py pgmakemigrations
./manage.py migrate
psql -c "insert into logistics_customer(uuid,first_name,last_name,address) select uuid_generate_v4(),md5(RANDOM()::TEXT),md5(RANDOM()::TEXT),md5(RANDOM()::TEXT) from generate_series(1,100);"
psql -c "insert into logistics_merchant(uuid,name,address,license) select uuid_generate_v4(),md5(RANDOM()::TEXT),md5(RANDOM()::TEXT),md5(RANDOM()::TEXT) from generate_series(1,100);"
psql -c "insert into logistics_order(uuid,created_at,updated_at,product,customer_id,merchant_id) select uuid_generate_v4(),NOW(),NOW(),uuid_generate_v4(),*,* from generate_series(1,99);"
psql -c "insert into logistics_delivery(uuid,created_at,updated_at,method,order_id) select uuid_generate_v4(),NOW(),NOW(),md5(RANDOM()::TEXT),* from generate_series(1,99);"
