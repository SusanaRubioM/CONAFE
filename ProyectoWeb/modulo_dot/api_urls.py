from django.urls import path
from .api_views import UsuarioAPI, DatosPersonalesAPI, ReporteFiguraEducativaAPI, CalificacionAPI, ActCAPAPI, PaymentScheduleAPI, ComunidadAPI, ReporteAcompAPI, AlumnoAPI

urlpatterns = [
    path('usuario/', UsuarioAPI.as_view(), name='usuario_list'),
    path('usuario/<int:pk>/', UsuarioAPI.as_view(), name='usuario_detail'),
    path('datos-personales/', DatosPersonalesAPI.as_view(), name='datospersonales_list'),
    path('datospersonales/<int:pk>/', DatosPersonalesAPI.as_view(), name='datospersonales_detail'),
    path('reporte/', ReporteFiguraEducativaAPI.as_view(), name='reporte_list'),
    path('reporte/<int:pk>/', ReporteFiguraEducativaAPI.as_view(), name='reporte_detail'),
    path('calificaciones/', CalificacionAPI.as_view(), name='calificaciones_list'),
    path('calificaciones/<int:pk>/', CalificacionAPI.as_view(), name='calificaciones_detail'),
    path('actcap/', ActCAPAPI.as_view(), name='actcap_list'),
    path('actcap/<int:pk>/', ActCAPAPI.as_view(), name='actcap_detail'),
    path('payments/', PaymentScheduleAPI.as_view(), name='payments_list'),
    path('payments/<int:pk>/', PaymentScheduleAPI.as_view(), name='payments_detail'),
    path('comunidades/', ComunidadAPI.as_view(), name='comunidad_list'),
    path('comunidades/<int:pk>/', ComunidadAPI.as_view(), name='comunidad_detail'),
    path('reportes-acomp/', ReporteAcompAPI.as_view(), name='reportes_acomp_list'),
    path('reportes-acomp/<int:pk>/', ReporteAcompAPI.as_view(), name='reportes_acomp_detail'),
       path('alumnos/', AlumnoAPI.as_view(), name='alumno-list'),  # Para obtener todos los alumnos o crear uno
    path('alumnos/<int:pk>/', AlumnoAPI.as_view(), name='alumno-detail')  # Para obtener, actualizar o eliminar un alumno específico
]

