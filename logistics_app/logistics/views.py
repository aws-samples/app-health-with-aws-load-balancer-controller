from django.shortcuts import render
from django.shortcuts import render
from logistics.models import Customer, Merchant, Order, Delivery
from django.utils import timezone
import datetime
import sys
from django.forms.models import model_to_dict

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
  order_objs= Order.objects.filter(updated_at__lte=timezone.now() - datetime.timedelta(seconds=10))[:1000]
  #order_objs=Order.objects.raw("select id,uuid,origin from logistics_order where created_at > NOW()-'10 sec'::INTERVAL").using('reader')
  recent_orders=order_objs.values('uuid')
  recent_orders_list=[]
  for i in recent_orders:
    recent_orders_list.append(str(i['uuid'])) 
  #print("in todaysorders_detail:recent_orders_list:{}".format(recent_orders_list))
  ordered_recent_orders=sorted(recent_orders_list)
  #print("in todaysorders_detail:ordered_recent_orders:{}".format(ordered_recent_orders))
  #sys.stdout.flush()
      
  context = {
      "orders": order_objs[:10],
  }
  return render(request, "orders_detail.html", context)

def allorders_detail(request):
  order_objs= Order.objects.all().using('reader')
  context = {
      "orders": order_objs,
  }
  return render(request, "orders_detail.html", context)
