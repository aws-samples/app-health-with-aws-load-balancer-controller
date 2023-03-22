FROM public.ecr.aws/docker/library/python:slim
RUN apt-get update -y --fix-missing
RUN apt-get install -y vim net-tools telnet jq unzip curl 

RUN /usr/local/bin/python -m pip install --upgrade pip
RUN pip install ec2-metadata

WORKDIR /usr/src/app
COPY requirements.txt ./
RUN pip install -r requirements.txt
COPY . .
