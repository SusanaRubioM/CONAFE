from django.urls import path
from . import views

app_name = 'coordinador_home'
urlpatterns = [
    path('home_coordinador/', views.empleado_view, name='home_coordinador'),  
    path('aspirante_dashboard/', views.dashboard_aspirantes, name='dashboard_aspirante'),
    path('aspirante_detalles/<int:aspirante_id>/', views.detalles_aspirante, name='detalles_aspirante')
]
