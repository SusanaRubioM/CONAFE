from django.urls import path
from . import views

app_name = 'modulo_apec'
urlpatterns = [
	path('home_apec/', views.home_view, name='home_apec'),
]