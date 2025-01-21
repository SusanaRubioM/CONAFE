from django.urls import path
from . import views

app_name='modulo_dpe'
urlpatterns = [
    path('home_dpe/', views.view_home_dpe, name='home_dpe'),
    path('dashboard/vacantes/dpe/', views.dashboard_vacantes_dpe, name='vacantes_dashboard'),
    path('dashboard/estadisticas/dpe/', views.estadisticas_dashboard, name='estadisticas_dashboard'),
    path('actualizar-estado-servicio/<int:servicio_id>/', views.actualizar_estado_servicio, name='actualizar_estado_servicio'),

]