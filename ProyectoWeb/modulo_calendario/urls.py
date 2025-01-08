from django.urls import path
from . import views

app_name = 'modulo_calendario'

urlpatterns = [
    path('visualizar/', views.visualizar_calendario, name='visualizar_calendario'),
    path('historial/', views.historial_calendario, name='historial_calendario'),
]
