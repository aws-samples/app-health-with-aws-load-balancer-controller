from django.shortcuts import redirect
import random

def redirect_view(request):
  app_number=random.randint(1,2)
  if app_number==1:
    redirect_to='/arm/runtime'
  if app_number==2:
    redirect_to='/amd/runtime'
  response = redirect(redirect_to)
  return response
