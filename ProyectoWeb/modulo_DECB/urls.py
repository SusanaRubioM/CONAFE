from django.urls import path
from . import views

app_name = 'modulo_DECB'

urlpatterns = [
    path('', views.home_decb, name='home'),
    path('calendario/', views.visualizar_calendario, name='visualizar_calendario'),
    path('asignar/', views.asignar_pagos, name='asignar_pagos'),
    path('historial/', views.historial_pagos, name='historial_pagos'),
    path('agregar-evento/', views.agregar_evento, name='agregar_evento'),

    # urls.py - Agregar esta nueva URL
    path('visualizar-pagos/', views.visualizar_pagos, name='visualizar_pagos'),
    path('asignar-pagos/', views.asignar_pagos, name='asignar_pagos'),
    path('calendario-eventos/', views.calendario_eventos, name='calendario_eventos'),  # Ruta correcta
    path('agregar-evento/', views.agregar_evento, name='agregar_evento'),
    path('historial-pagos/', views.historial_pagos, name='historial_pagos'),
    path('marcar-pago-completado/<int:payment_id>/', views.mark_payment_completed, name='mark_payment_completed'),

]
