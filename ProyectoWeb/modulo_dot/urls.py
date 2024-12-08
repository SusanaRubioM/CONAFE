from django.urls import path
from . import views

app_name = 'dot_home'

urlpatterns = [
    path('home_dot/', views.home_view, name='home_dot'),
    path('agregar_usuario/', views.agregar_trabajador, name='home_agregar'),
    path('visualizar_dashboard/', views.dashboard_view, name='dashboard_visualizar'),
    path('detalles_empleado/<int:empleado_id>/', views.detalles_empleado, name='detalles_empleado'),
    path('modificar_dashboard/', views.modificar_dashboard, name='dashboard_modificar'),  # Configuración correcta
    path('empleado_modificar/<int:empleado_id>/', views.modificar_empleado, name='modificar_empleado'),
]





