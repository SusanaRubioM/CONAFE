from django.urls import path
from . import views

app_name = 'modulo_capacitacion'

urlpatterns = [
    path('', views.lista_vacantes_asignadas, name='lista_capacitaciones'),
    path('crear/', views.crear_asignacion, name='crear_capacitacion'),
    path('editar/<int:capacitacion_id>/', views.editar_asignacion, name='editar_capacitacion'),
    path('finalizar/<int:capacitacion_id>/', views.finalizar_asignacion, name='finalizar_capacitacion'),
    path('api/usuarios/<int:usuario_id>/', views.obtener_datos_usuario, name='get_usuario_data'),
]

