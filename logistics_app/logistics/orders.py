from django.shortcuts import render
from django.shortcuts import render
from logistics.models import Customer, Merchant, Order, Delivery
from django.db.models import Max
from django.utils import timezone

import uuid
from random import randrange
import random
import string

def authuser(request):
  max_cust_id=Customer.objects.all().aggregate(Max('id'))['id__max']
  cust_id=randrange(2,max_cust_id)
  customer=Customer.objects.get(id=randrange(2,Customer.objects.all().aggregate(Max('id'))['id__max']))
  context = {
      "customer": customer,
  }
  return render(request, "authuser.html", context)

def insert(request):
  order_uuid=uuid.uuid1()
  order_created_at=timezone.now()
  order_updated_at=timezone.now()
  order_product=uuid.uuid1()
#  try:
  order_merchant_id=Merchant.objects.get(id=randrange(2,Merchant.objects.all().aggregate(Max('id'))['id__max'])).id
#  except Exception:
#  merchant=uuid.uuid1()
#  merchant_name=''.join(random.choices(string.ascii_letters + string.digits, k=20))
#  merchant_address=''.join(random.choices(string.ascii_letters + string.digits, k=20))
#  merchant_license=''.join(random.choices(string.ascii_letters + string.digits, k=20))
#  merchant=Merchant(uuid=merchant,name=merchant_name,address=merchant_address,license=merchant_license)
#  order_merchant_id=Merchant.objects.get(id=randrange(2,Merchant.objects.all().aggregate(Max('id'))['id__max'])).id
  order_customer_id=Customer.objects.get(id=randrange(2,Customer.objects.all().aggregate(Max('id'))['id__max'])).id
  order_obj=Order(uuid=order_uuid,created_at=order_created_at,updated_at=order_updated_at,product=order_product,customer_id=order_customer_id,merchant_id=order_merchant_id)
  order_obj.save()
  context = {
      "order": order_obj,
  }

  return render(request, "order_detail.html", context)

def update(request, uuid):
  order_obj= Order.objects.get(uuid=uuid)
  order_obj.updated_at=timezone.now()
  order_obj.save()
  context = {
      "order": order_obj,
  }
  return render(request, "order_detail.html", context)
