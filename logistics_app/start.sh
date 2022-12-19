#!/bin/bash

sed -i "s/PGUSER/$PGUSER/g" django_app/settings.py 
sed -i "s/PGDATABASE/$PGDATABASE/g" django_app/settings.py 
sed -i "s/PGPASSWORD/$PGPASSWORD/g" django_app/settings.py 
sed -i "s/PGHOST/$PGHOST/g" django_app/settings.py 
sed -i "s/PGPORT/$PGPORT/g" django_app/settings.py 
#CMD ["python", "manage.py", "runserver", "0.0.0.0:8000"]
#CMD ["python", "manage.py", "runsslserver", "0.0.0.0:8000"]
python ./manage.py runserver 0.0.0.0:8000

