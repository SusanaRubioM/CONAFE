from django.urls import path
from .api_views import UsuarioAPI  # Importa tus vistas de la API

urlpatterns = [
    path('usuario/', UsuarioAPI.as_view(), name='usuario_list'),
    path('usuario/<int:pk>/', UsuarioAPI.as_view(), name='usuario_detail'),
]
