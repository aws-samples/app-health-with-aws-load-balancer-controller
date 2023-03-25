#FROM public.ecr.aws/docker/library/python:slim
FROM python:3.9
RUN apt-get update -y --fix-missing
RUN apt-get install -y vim net-tools telnet jq unzip curl 

RUN /usr/local/bin/python -m pip install --upgrade pip
RUN pip install ec2-metadata

#Install aws cli
RUN pip install awscli
RUN mkdir /root/.aws
COPY config /root/.aws

WORKDIR /usr/src/app
COPY requirements.txt ./
RUN pip install -r requirements.txt
COPY . .
