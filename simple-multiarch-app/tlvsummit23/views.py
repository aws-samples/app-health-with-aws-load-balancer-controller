from django.shortcuts import render
from ec2_metadata import ec2_metadata
import os
import sys

def get_runtime(request):
  _pod_name=os.environ['POD_NAME']
  _pod_ip=os.environ['POD_IP']
  _instance_type=ec2_metadata.instance_type
  _availability_zone_id=ec2_metadata.availability_zone_id
  _hostname=ec2_metadata.private_hostname
  runtime_obj={'pod_name':_pod_name,'pod_ip':_pod_ip,'instance_type':_instance_type,'availability_zone_id':_availability_zone_id,'hostname':_hostname}
  #print('runtime_obj='+str(runtime_obj))
  #sys.stdout.flush()
  context = {"instance_runtime":runtime_obj}
  return render(request,"runtime_detail.html",context)
