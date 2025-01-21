
# login_app/urls.py
from django.urls import path
from . import views

urlpatterns = [
    path('', views.form_view, name='formulario_aspirante'),  # Ruta principal del formulario
    path('registrar/', views.form_view, name='registrar_aspirante'),  # Registro del aspirante
    path('confirmacion/', views.confirmacion, name='confirmacion'),  # Página de confirmación
]
