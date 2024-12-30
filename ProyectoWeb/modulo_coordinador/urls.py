from django.urls import path
from . import views

app_name = 'coordinador_home'
urlpatterns = [
    path('home_coordinador/', views.empleado_view, name='home_coordinador'),  
    path('aspirante_dashboard/', views.dashboard_aspirantes_ec, name='dashboard_aspirante'),
    path('aspirante_detalles/<int:aspirante_id>/', views.detalles_aspirante, name='detalles_aspirante'),
    path('actualizar_status_ajax/<int:aspirante_id>/', views.ajax_aspirante_status, name='actualizar_status_ajax'),
    path('crear_usuario_ajax/', views.crear_usuario_ajax, name='crear_usuario_ajax'),
    path('aspirante_rechazado/', views.dashboard_aspirantes_rechazados, name='dashboard_aspirante_rechazado'),
    path('aspirante_aceptado/', views.dashboard_aspirantes_aceptados, name='dashboard_aspirante_aceptado'),
    path('aspirante_dashboard_eca_ecar/', views.dashboard_aspirantes_eca_ecar, name='dashboard_aspirante_eca_ecar'),
    path('aspirante_aceptado_eca_ecar/', views.dashboard_aspirantes_aceptados_eca_ecar, name='dashboard_aspirante_aceptado_eca_ecar'),
    path('aspirante_rechazado_eca_ecar/', views.dashboard_aspirantes_rechazados_eca_ecar, name='dashboard_aspirante_rechazado_eca_ecar'),
      
]
