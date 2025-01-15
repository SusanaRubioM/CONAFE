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
    path('dashboard/figura/educativas/', views.dashboard_figura_educativa, name='dashboard_figura_educativa'),
    path('detalles_educador/<int:empleado_id>/', views.detalles_educador, name='detalles_educador'),
    path('vacantes/dashboard/ct', views.dashboard_vacantes_ct, name='dashboard_vacantes_ct'),
    #aq
    path('asignar/vacantes', views.dashboard_asignar, name='asignar_dashboard'),
    path('vacantes/dashboards/asignacion_vacantes/<int:servicio_id>/', views.asignacion_vacantes_view_ct, name='asignacion_vacantes_ct'),
    path('observacion/exitosa', views.exito_view_ct, name='view_exito_ct'),
    #reportes
    path('menu/reportes', views.menu_reportes_ct, name='menu_reportes_ct'),
    path('dashboard/equipamiento', views.dashboard_equipamiento, name='dashboard_equipamiento'),
    path('dashboard/capacitacion/', views.dashboard_capacitacion_pdf, name='dashboard_capacitacion_pdf'),
    path('dashboard/seguimiento/', views.dashboard_seguim_pdf, name='dashboard_seguim_pdf'),
    path('reporte/<int:reporte_id>/validar-rechazar', views.validar_rechazar_reporte, name='validar_rechazar_reporte'),
    #GIS
    path('gestion_RMR/dashboard/ct', views.dashboard_gestion_RMR, name='gestion_RMR_dashboard_ct'),
    path('gestion_estado/dashboard/ct', views.dashboard_gestion_estado, name='estado_estado'),
    #CONVENIOS
    path('dashboard/convenios/', views.dashboard_convenio_view, name='dashboard_convenios'),
    path('convenio/<int:convenio_id>/actualizar-estado/', 
         views.actualizar_estado_convenio, 
         name='actualizar_estado_convenio'),
]
      
