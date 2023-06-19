#!/bin/bash
export ARCH=$(uname -m)
python ./manage.py runserver 0.0.0.0:8000
