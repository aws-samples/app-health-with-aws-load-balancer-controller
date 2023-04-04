from django.urls import path

from . import views
from . import health


urlpatterns = [
  path("runtime/",views.get_runtime,name="get_runtime"),
  path("health/",health.show,name="health"),
]
