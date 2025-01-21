from django.contrib import admin
from django.urls import path, include
from django.shortcuts import redirect
from django.conf.urls.static import static

from django.conf import settings
from django.conf.urls.static import static


# Vista para redirigir a login
def redirect_to_login(request):
    return redirect("login")  # Redirige a la URL de login definida en 'login_app.urls'


urlpatterns = [

    path('capacitacion/', include('modulo_capacitacion.urls')),
    path('modulo_educadores/', include('modulo_educadores.urls')),

    path('modulo_pagos/', include('modulo_pagos.urls')),  # Incluye las rutas de modulo_pagos
    path('modulo_calendario/', include('modulo_calendario.urls')),  # Incluye las rutas de modulo_calendario

    path("admin/", admin.site.urls),
    path('modulo_DECB/', include('modulo_DECB.urls')),  # Incluye las rutas del módulo DECB
    path(
        "", redirect_to_login
    ),  # Redirige a la página de login cuando acceden a la raíz
    path('formulario_aspirante/', include('form_app.urls')),
    path("login/", include("login_app.urls")),  # Redirige a las URLs de login
    path('api/', include('modulo_dot.api_urls')),  # Rutas exclusivas de la API
    path(
        "dot_section/", include(("modulo_dot.urls", "dot_home"), namespace="dot_home")
    ),
    path(
        "empleado_section/",
        include(
            ("home_empleado.urls", "dashboard_empleado"), namespace="dashboard_empleado"
        ),
    ),
    path(
        "coordinador_section/",
        include(
            ("modulo_coordinador.urls", "coordinador_home"),
            namespace="coordinador_home",
        ),
    ),
    path(
        "apec_section/",
        include(("modulo_apec.urls", "modulo_apec"), namespace="modulo_apec"),
    ),
    path(
        "dpe_section/",
        include(
            ("modulo_dpe.urls", "modulo_dpe"), 
            namespace="modulo_dpe"),
    ),
]


# Servir archivos de medios durante el desarrollo
if settings.DEBUG:
    urlpatterns += static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)

