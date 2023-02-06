FROM python:3.9

RUN apt-get update
RUN apt -y --fix-missing update
RUN DEBIAN_FRONTEND=noninteractive apt-get install --fix-missing -y postgresql
RUN apt install -y jq

WORKDIR /usr/src/app
COPY requirements.txt ./
RUN pip install -r requirements.txt
COPY . .
