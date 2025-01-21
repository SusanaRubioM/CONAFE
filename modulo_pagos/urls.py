from django.urls import path
from . import views

app_name = 'modulo_pagos'

urlpatterns = [
    path('asignar/', views.asignar_pagos, name='asignar_pagos'),
    path('historial/', views.historial_pagos, name='historial_pagos'),
]
