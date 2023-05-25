FROM public.ecr.aws/docker/library/python:slim
#FROM python:3.9
RUN apt-get update -y --fix-missing
RUN apt-get install -y vim net-tools telnet jq unzip curl gnupg2 apt-utils

RUN /usr/local/bin/python -m pip install --upgrade pip
RUN pip install ec2-metadata

#Install aws cli
RUN pip install awscli
RUN mkdir /root/.aws
COPY config /root/.aws

RUN apt-get install -y tcpdump
RUN tcpdump --version
RUN which tcpdump

#Install kubectl for the simulator pod scaler
#RUN apt-get install -y apt-transport-https ca-certificates

#RUN curl -fsSLo /etc/apt/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg
#RUN echo "deb [signed-by=/etc/apt/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | tee /etc/apt/sources.list.d/kubernetes.list
#RUN apt-get update && \
#    apt-get install -y apt-transport-https ca-certificates curl && \
#    curl -fsSLo /etc/apt/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg && \
#    echo "deb [signed-by=/etc/apt/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | tee /etc/apt/sources.list.d/kubernetes.list && \
#    apt-get update && \
#    apt-get install -y kubectl
#RUN kubectl version --client

WORKDIR /usr/src/app
COPY requirements.txt ./
RUN pip install -r requirements.txt
COPY . .
