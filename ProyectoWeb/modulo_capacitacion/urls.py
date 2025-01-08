from django.urls import path
from . import views

app_name = 'modulo_capacitacion'

urlpatterns = [
    path('', views.lista_capacitaciones, name='lista_capacitaciones'),
    path('crear/', views.crear_capacitacion, name='crear_capacitacion'),
    path('editar/<int:capacitacion_id>/', views.editar_capacitacion, name='editar_capacitacion'),
    path('finalizar/<int:capacitacion_id>/', views.finalizar_capacitacion, name='finalizar_capacitacion'),
]
