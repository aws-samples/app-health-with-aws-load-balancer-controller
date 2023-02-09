from django.shortcuts import render
from django.shortcuts import render
from logistics.models import Customer, Merchant, Order, Delivery
from django.utils import timezone
import datetime
import sys
from django.forms.models import model_to_dict
import numpy as np
import pandas as pd

def order_detail(request, uuid):
  order_obj= Order.objects.get(uuid=uuid).using('reader')
  delivery_objs=Delivery.objects.filter(order_id=order_obj.id).using('reader')
  #delivery_obj=Delivery.objects.raw('SELECT * FROM logistics_delivery WHERE order_id='+str(order_obj.id)+' LIMIT 1')
  context = {
      "order": order_obj,
      "deliveries": delivery_objs,
  }
  return render(request, "order_detail.html", context)

def todaysorders_detail(request):
  order_objs= Order.objects.filter(updated_at__lte=timezone.now() - datetime.timedelta(seconds=10))[:20000]
  #order_objs=Order.objects.raw("select id,uuid,origin from logistics_order where created_at > NOW()-'10 sec'::INTERVAL").using('reader')
  
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
  
  for i in range(3): 
    product_uuid_df=product_df.dot(uuid_df)
    uuid_product_df=uuid_df.dot(product_df)

  recent_orders_origin=order_objs.values('origin')
  recent_orders_origin_list=[]
  for i in recent_orders_origin:
    recent_orders_origin_list.append(str(i['origin'])) 
  ordered_recent_orders_origin=sorted(recent_orders_origin_list)
  ordered_recent_orders_origin_rev=sorted(recent_orders_origin_list,reverse=True)

  context = {
      "orders": order_objs[:2],
  }
  return render(request, "orders_detail.html", context)

def allorders_detail(request):
  order_objs= Order.objects.all().using('reader')
  context = {
      "orders": order_objs,
  }
  return render(request, "orders_detail.html", context)
