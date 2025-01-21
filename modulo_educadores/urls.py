from django.urls import path
from . import views

app_name = 'modulo_educadores'

urlpatterns = [

    path('', views.home_educador, name='home'),
    path('home/', views.home_educador, name='home_educador'),
    path('calendario/', views.calendario_educador, name='calendario_educador'),  # Asegúrate de que esta línea exista
    path('confirmar/<int:payment_id>/', views.confirmar_recepcion, name='confirmar_recepcion'),

    path('confirmar-recepcion/<int:payment_id>/', views.confirmar_recepcion, name='confirmar_recepcion'),
]
