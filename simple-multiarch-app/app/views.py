from django.shortcuts import render
from ec2_metadata import ec2_metadata
import os
import sys
import numpy as np
import pandas as pd
from multiprocessing import Pool
import uuid
import boto3

cloudwatch_client = boto3.client('cloudwatch')
sqs_client=boto3.client('sqs')

_pod_name=os.environ['POD_NAME']
_pod_ip=os.environ['POD_IP']
_arch=os.environ['ARCH']
_cloudwatch_namespace=os.environ['CW_NS']
_matrix_dim=int(os.environ['MATRIX_DIM'])


def get_runtime(request):
  try:
    _job=uuid.uuid1()
    #sqs_response=sqs_client.send_message(MessageBody=str(_job),QueueUrl=app_queue) 
    #print("sqs_response:{}".format(sqs_response))
    _instance_type=ec2_metadata.instance_type
    _availability_zone_id=ec2_metadata.availability_zone_id
    _hostname=ec2_metadata.private_hostname
    runtime_obj={'pod_name':_pod_name,'pod_ip':_pod_ip,'instance_type':_instance_type,'availability_zone_id':_availability_zone_id,'hostname':_hostname}
    df1 = pd.DataFrame(data=np.random.randint(_matrix_dim,size=(_matrix_dim,_matrix_dim)));
    df2 = pd.DataFrame(data=np.random.randint(_matrix_dim,size=(_matrix_dim,_matrix_dim)));
    df12 = np.matmul(df1,df2)
    print("df1={}".format(df1)) 
    print("df2={}".format(df2)) 
    print("df12={}".format(df12)) 
    sys.stdout.flush()
    context = {"instance_runtime":runtime_obj}
    response = cloudwatch_client.put_metric_data(
      MetricData = [
        {
          'MetricName': _arch,
          'Unit': 'Count',
          'Value': 200 
        },
      ],
      Namespace=_cloudwatch_namespace
    )
    print("response from cw".format(response)) 
    sys.stdout.flush()
  except:
    response = cloudwatch_client.put_metric_data(
      MetricData = [
        {
          'MetricName': _arch,
          'Unit': 'Count',
          'Value': 504
        },
      ],
      Namespace=_cloudwatch_namespace
    )
    print("response from cw".format(response)) 
    sys.stdout.flush()
    raise
  return render(request,"runtime_detail.html",context)
