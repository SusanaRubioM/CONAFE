from django.urls import path
from . import views

app_name = 'modulo_apec'

urlpatterns = [
    path('home_apec/', views.home_view, name='home_apec'),
    path('vacantes/dashboards/observaciones/', views.observaciones_view, name='observaciones'),
    path('vacantes/dashboards/asignacion_vacantes/<int:servicio_id>/', views.asignacion_vacantes_view, name='asignacion_vacantes'),
    path('observacion/exitosa', views.exito_view, name='view_exito')
]
