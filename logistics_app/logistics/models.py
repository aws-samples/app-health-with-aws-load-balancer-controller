from django.db import models
from psqlextra.types import PostgresPartitioningMethod
from psqlextra.models import PostgresPartitionedModel
from uuid import uuid4

class Customer(models.Model):
  uuid = models.UUIDField(null=False)
  first_name = models.CharField(max_length=50,null=False)
  last_name = models.CharField(max_length=50,null=False)
  address = models.CharField(max_length=150,null=False)

class Merchant(models.Model):
  uuid = models.UUIDField(null=False)
  name = models.CharField(max_length=50,null=False)
  address = models.CharField(max_length=150,null=False)
  license = models.CharField(max_length=50,null=False)

class Order(PostgresPartitionedModel):
  class PartitioningMeta:
    method = PostgresPartitioningMethod.RANGE
    key = ["created_at"]

  uuid = models.UUIDField(null=False,default=uuid4,editable=False)
  created_at = models.DateTimeField(null=False)
  updated_at = models.DateTimeField(null=False)
  product = models.UUIDField(null=False,default=uuid4,editable=False)
  product_desc = models.UUIDField(null=False,default=uuid4,editable=False)
  customer_desc = models.UUIDField(null=False,default=uuid4,editable=False)
  origin = models.UUIDField(null=False,default=uuid4,editable=False)
  dest = models.UUIDField(null=False,default=uuid4,editable=False)
  manufacturer = models.UUIDField(null=False,default=uuid4,editable=False)
  order_group = models.UUIDField(null=False,default=uuid4,editable=False)
  purchase_order = models.UUIDField(null=False,default=uuid4,editable=False)
  required_by = models.UUIDField(null=False,default=uuid4,editable=False)
  unit = models.UUIDField(null=False,default=uuid4,editable=False)
  order_user = models.UUIDField(null=False,default=uuid4,editable=False)
  payment = models.UUIDField(null=False,default=uuid4,editable=False)
  bill_to = models.UUIDField(null=False,default=uuid4,editable=False)
  bill_address = models.UUIDField(null=False,default=uuid4,editable=False)
  #merchant  = models.ForeignKey("Merchant", on_delete=models.CASCADE,null=True)
  #customer = models.ForeignKey("Customer", on_delete=models.CASCADE,null=True)
  customer_id = models.BigIntegerField(null=True)
  merchant_id = models.BigIntegerField(null=True)


class Delivery(PostgresPartitionedModel):
  class PartitioningMeta:
    method = PostgresPartitioningMethod.RANGE
    key = ["created_at"]

  uuid = models.UUIDField(null=False)
  created_at = models.DateTimeField(null=False)
  method = models.CharField(max_length=50,null=False)
  status = models.CharField(max_length=50,null=True)
  updated_at = models.DateTimeField(null=False)
  order_id = models.BigIntegerField(null=True)
  product = models.UUIDField(null=False,default=uuid4,editable=False)
  product_desc = models.UUIDField(null=False,default=uuid4,editable=False)
  customer_desc = models.UUIDField(null=False,default=uuid4,editable=False)
  origin = models.UUIDField(null=False,default=uuid4,editable=False)
  dest = models.UUIDField(null=False,default=uuid4,editable=False)
  manufacturer = models.UUIDField(null=False,default=uuid4,editable=False)
  order_group = models.UUIDField(null=False,default=uuid4,editable=False)
  purchase_order = models.UUIDField(null=False,default=uuid4,editable=False)
  required_by = models.UUIDField(null=False,default=uuid4,editable=False)
  unit = models.UUIDField(null=False,default=uuid4,editable=False)
  order_user = models.UUIDField(null=False,default=uuid4,editable=False)
  payment = models.UUIDField(null=False,default=uuid4,editable=False)
  bill_to = models.UUIDField(null=False,default=uuid4,editable=False)
  bill_address = models.UUIDField(null=False,default=uuid4,editable=False)
