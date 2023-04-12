from django.shortcuts import redirect
import random
import requests
import os

url = os.environ['APP_ENDPOINT']

def redirect_view(request):
  app_number=random.randint(1,2)
  if app_number==1:
    response = requests.get('http://'+url+'/arm/runtime/')
    if (response.status_code==200):
      redirect_to='/arm/runtime'
    else:
      redirect_to='/amd/runtime'
  if app_number==2:
    response = requests.get('http://'+url+'/amd/runtime/')
    if (response.status_code==200):
      redirect_to='/amd/runtime'
    else:
      redirect_to='/arm/runtime'

  response = redirect(redirect_to)
  return response
