from django.urls import path

from . import views
from . import health


urlpatterns = [
  path("runtime/",views.redirect_view,name="redirect_view"),
  path("health/",health.show,name="health"),
]
