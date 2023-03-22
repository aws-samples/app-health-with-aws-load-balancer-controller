from django.shortcuts import render
from django.shortcuts import render
from logistics.models import Customer, Merchant, Order, Delivery
from django.db.models import Max
from django.utils import timezone
import datetime
import boto3
import uuid
from random import randrange
import random
import string
import sys
import os
import numpy as np
import pandas as pd

sqs_client = boto3.client('sqs')
orders_queue=os.environ['ORDER_QUEUE']

def authuser(request):
  max_cust_id=Customer.objects.all().aggregate(Max('id'))['id__max'].using('reader')
  cust_id=randrange(2,max_cust_id)
  customer=Customer.objects.get(id=randrange(2,Customer.objects.all().aggregate(Max('id'))['id__max'])).using('reader')
  context = {
      "customer": customer,
  }
  return render(request, "authuser.html", context)

def insert(request):
  #for i in range(2):
  #i=do_cpu_work(request)
  order_obj=insert_single
  context = {
      "order": order_obj,
  }
  return render(request, "order_detail.html", context)

def do_cpu_work(request):
  order_objs= Order.objects.filter(updated_at__lte=timezone.now() - datetime.timedelta(seconds=10))[:20000]
  recent_orders_uuid=order_objs.values('uuid')
  recent_orders_uuid_list=[]
  for i in recent_orders_uuid:
    recent_orders_uuid_list.append(i['uuid'].int>>64)

  ordered_recent_orders_uuid=sorted(recent_orders_uuid_list)
  ordered_recent_orders_uuid_rev=sorted(recent_orders_uuid_list,reverse=True)
  
  uuid_series=pd.Series(recent_orders_uuid_list[:400])
  uuid_chunks=np.split(uuid_series,20,axis=0)
  uuid_nd=np.stack(uuid_chunks)
  uuid_df=pd.DataFrame(uuid_nd)
  
  recent_orders_product=order_objs.values('product')
  recent_orders_product_list=[]
  for i in recent_orders_product:
    recent_orders_product_list.append(i['product'].int>>64)
  ordered_recent_orders_product=sorted(recent_orders_product_list)
  ordered_recent_orders_product_rev=sorted(recent_orders_product_list,reverse=True)

  product_series=pd.Series(recent_orders_product_list[:400])
  product_chunks=np.split(product_series,20,axis=0)
  product_nd=np.stack(product_chunks)
  product_df=pd.DataFrame(product_nd)
  for i in range(2):
    product_uuid_df=product_df.dot(uuid_df)
    uuid_product_df=uuid_df.dot(product_df)
  return 0

def insert_single():
  order_uuid=uuid.uuid1()
  product_desc=uuid.uuid1()
  customer_desc=uuid.uuid1()
  origin=uuid.uuid1()
  dest=uuid.uuid1()
  manufacturer=uuid.uuid1()
  
  order_created_at=timezone.now()
  order_updated_at=timezone.now()
  order_product=uuid.uuid1()
  bill_address=uuid.uuid1()
  bill_to=uuid.uuid1()
  order_group=uuid.uuid1()
  order_user=uuid.uuid1()
  payment=uuid.uuid1()
  purchase_order=uuid.uuid1()
  required_by=uuid.uuid1()
  unit=uuid.uuid1()
  
  order_merchant_id=Merchant.objects.using('reader').get(id=randrange(2,Merchant.objects.all().aggregate(Max('id'))['id__max'])).id
  order_customer_id=Customer.objects.using('reader').get(id=randrange(2,Customer.objects.all().aggregate(Max('id'))['id__max'])).id
  order_obj=Order(uuid=order_uuid,created_at=order_created_at,updated_at=order_updated_at,product=order_product,customer_id=order_customer_id,merchant_id=order_merchant_id,product_desc=product_desc,customer_desc=customer_desc,origin=origin,dest=dest,manufacturer=manufacturer,bill_address=bill_address,bill_to=bill_to,order_group=order_group,order_user=order_user,payment=payment,purchase_order=purchase_order,required_by=required_by,unit=unit)
  print("in orders:insert: new order: {}".format(order_obj.uuid))
  sys.stdout.flush()
  order_obj.save(using='writer')
  response=sqs_client.send_message(MessageBody=str(order_obj.id),QueueUrl=orders_queue)
  return order_obj

def update(request, uuid):
  order_obj= Order.objects.using('reader').get(uuid=uuid)
  order_obj.updated_at=timezone.now()
  order_obj.save(using='writer')
  context = {
      "order": order_obj,
  }
  return render(request, "order_detail.html", context)

def update_from_sqs(request):
  for i in range(2):
#    print("in orders:update_from_sqs: new update thread: {}".format(i))
#    sys.stdout.flush()
    #i=do_cpu_work(request)
    order_obj=update_from_sqs_single 
  context = {
      "order": order_obj,
  }
  return render(request, "order_detail.html", context)

def update_from_sqs_single():
  response=sqs_client.receive_message(MaxNumberOfMessages=1,QueueUrl=orders_queue)
  order_id=response['Messages'][0]['Body']
  receipt_handle=response['Messages'][0]['ReceiptHandle']
  order_obj= Delivery.objects.using('reader').get(id=order_id)
  order_obj.updated_at=timezone.now()
  response=sqs_client.delete_message(ReceiptHandle=receipt_handle,QueueUrl=orders_queue)
  #print("response from delete message:{}".format(response))
  #sys.stdout.flush()
  order_obj.save(using='writer')
  return order_obj
