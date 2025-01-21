from django.urls import path
from . import views
app_name = 'dashboard_empleado'
urlpatterns = [
    path('home_empleado/', views.empleado_view, name='home_empleado'),  # Define la vista de home_empleado
]



