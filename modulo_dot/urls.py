from django.urls import path
from . import views 
from django.conf import settings
from django.conf.urls.static import static  # Asegúrate de esta importación

app_name = 'dot_home'

urlpatterns = [
    path('home_dot/', views.home_view, name='home_dot'),
    path('agregar_usuario/', views.agregar_trabajador, name='home_agregar'),
    path('visualizar_dashboard/', views.dashboard_view, name='dashboard_visualizar'),
    path('detalles_empleado/<int:empleado_id>/', views.detalles_empleado, name='detalles_empleado'),
    path('modificar_dashboard/', views.modificar_dashboard, name='dashboard_modificar'),  # Configuración correcta
    path('empleado_modificar/<int:empleado_id>/', views.modificar_empleado, name='modificar_empleado'),
    path('dasboard/status/', views.status_empleado, name='dasboard_status'),
    path('ajax/empleado/status/<int:empleado_id>/', views.actualizar_status_ajax, name='actualizar_status_ajax'),
    path('dashboard/eliminar/', views.dashboard_eleminar, name='dashboard_eleminar'),
    path('eliminar/<int:empleado_id>/', views.eliminar_empleado, name='empleado_eliminar'),
    path('visualizacion/docs/', views.visualizar_docs, name='visualizacion_docs'),
    path('dashboard/vacantes/', views.dashboard_vacantes, name='dashboard_vacantes'),
    path('dashboard/convenios/', views.dashboard_convenios, name='dashboard_convenios'),
    path('guardar-firma/', views.save_signature, name='save_signature'),
    


]






