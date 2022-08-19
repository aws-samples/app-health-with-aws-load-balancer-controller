from django.shortcuts import render
from django.shortcuts import render
from logistics.models import Customer, Merchant, Order, Delivery
#from datetime import date
#from datetime import datetime,timezone
from django.utils import timezone

def order_detail(request, uuid):
  order_obj= Order.objects.get(uuid=uuid)
  delivery_objs=Delivery.objects.filter(order_id=order_obj.id)
  #delivery_obj=Delivery.objects.raw('SELECT * FROM logistics_delivery WHERE order_id='+str(order_obj.id)+' LIMIT 1')
  context = {
      "order": order_obj,
      "deliveries": delivery_objs,
  }
  return render(request, "order_detail.html", context)

def todaysorders_detail(request):
  #order_objs= Order.objects.filter(created_at=date.today())
  #order_objs= Order.objects.filter(created_at=datetime.utcnow().replace(tzinfo=timezone.utc))
  #order_objs= Order.objects.filter(created_at=timezone.now())
  order_objs=Order.objects.raw("select * from logistics_order where created_at > NOW()-'10 sec'::INTERVAL")
  context = {
      "orders": order_objs,
  }
  return render(request, "orders_detail.html", context)

def allorders_detail(request):
  order_objs= Order.objects.all()
  context = {
      "orders": order_objs,
  }
  return render(request, "orders_detail.html", context)
