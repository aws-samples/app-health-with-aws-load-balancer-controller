from django.shortcuts import render
from django.shortcuts import render
from logistics.models import Customer, Merchant, Order, Delivery
from django.db.models import Max
from django.utils import timezone

import boto3
import uuid
from random import randrange
import random
import string
import sys
import os
import json

sqs_client = boto3.client('sqs')
orders_queue=os.environ['ORDER_QUEUE']
deliveries_queue=os.environ['DELIVERY_QUEUE']


def update(request):
  for i in range(2):
    #print("in deliveries:update: new update thread: {}".format(i))
    #sys.stdout.flush()
    delivery_obj=update_single
  context = {
      "delivery": delivery_obj,
  }
  return render(request, "delivery.html", context)

def update_single():
  response=sqs_client.receive_message(MaxNumberOfMessages=1,QueueUrl=deliveries_queue)
  delivery_id=response['Messages'][0]['Body']
  receipt_handle=response['Messages'][0]['ReceiptHandle']
  delivery_obj= Delivery.objects.using('reader').get(id=delivery_id)
  delivery_obj.updated_at=timezone.now()
  delivery_obj.save(using='writer')
  response=sqs_client.delete_message(ReceiptHandle=receipt_handle,QueueUrl=deliveries_queue)
  #print("response from delete message:{}".format(response))
  #sys.stdout.flush()
  return delivery_obj

