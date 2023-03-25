from django.shortcuts import render
from django.shortcuts import render

def show(request):
  
  context = {
      "name": "healthy",
  }
  return render(request, "health.html", context)
