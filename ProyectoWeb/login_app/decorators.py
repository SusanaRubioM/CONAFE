from django.contrib.auth.decorators import login_required
from django.core.exceptions import PermissionDenied
from django.shortcuts import redirect

# Decorador para comprobar el rol
def role_required(*roles):  # Ahora puede recibir varios roles
    def decorator(view_func):
        @login_required
        def _wrapped_view(request, *args, **kwargs):
            # Depuración: muestra el rol del usuario
            print(f"User Role: {request.user.role}")

            if request.user.role in roles:
                return view_func(request, *args, **kwargs)
            else:
                # Opcional: Redirigir a una página de error o mostrar un mensaje
                return redirect('access_denied')  # Redirigir a una página de acceso denegado

                # Alternativamente: 
                # raise PermissionDenied("No tienes permisos suficientes para acceder a esta página.")
        return _wrapped_view
    return decorator

