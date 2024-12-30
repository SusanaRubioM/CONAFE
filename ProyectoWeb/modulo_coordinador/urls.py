from django.urls import path
from . import views

app_name = 'coordinador_home'
urlpatterns = [
    path('home_coordinador/', views.empleado_view, name='home_coordinador'),  
    path('aspirante_dashboard/', views.dashboard_aspirantes_ec, name='dashboard_aspirante'),
    path('aspirante_dashboard_eca_ecar/', views.dashboard_aspirantes_eca_ecar, name='dashboard_aspirante_eca_ecar'),
    path('aspirante_detalles/<int:aspirante_id>/', views.detalles_aspirante, name='detalles_aspirante'),
    path('actualizar_status_ajax/<int:aspirante_id>/', views.ajax_aspirante_status, name='actualizar_status_ajax'),
]
