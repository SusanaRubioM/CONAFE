from django.shortcuts import render, get_object_or_404
from login_app.decorators import role_required
from django.contrib.auth.decorators import login_required
from form_app.models import Aspirante, Usuario
from django.contrib.auth.hashers import make_password
from login_app.models import UsuarioRol
from django.db.models import Prefetch
from django.http import JsonResponse
import json
from django.core.exceptions import ObjectDoesNotExist

@login_required
@role_required('CT')
def empleado_view(request):
    # Lógica específica para el coordinador territorial
    return render(request, 'home_coordinador/home_coordinador.html')


def dashboard_aspirantes_ec(request):
    aspirantes = (
        Aspirante.objects
        .select_related(
            "datos_personales",
            "datos_personales__documentos",  # Relación de DocumentosPersonales
            "residencia",
            "participacion",
            "gestion",
            "usuario",
        )
        .all()
    )
    return render(
        request,
        "home_coordinador/dashboard_aspirante.html",
        {"aspirantes": aspirantes},
    )


def dashboard_aspirantes_eca_ecar(request):
    aspirantes = (
        Aspirante.objects
        .select_related(
            "datos_personales",
            "datos_personales__documentos",  # Relación de DocumentosPersonales
            "residencia",
            "participacion",
            "gestion",
            "usuario",
        )
        .filter(participacion__programa_participacion__in=["ECA", "ECAR"])
    )
    return render(
        request,
        "home_coordinador/dashboard_aspirante_ecar.html",
        {"aspirantes": aspirantes},
    )


def ajax_aspirante_status(request, aspirante_id):
    if request.method == "POST":
        try:
            # Obtener los datos del cuerpo de la solicitud en formato JSON
            data = json.loads(request.body)
            status_seleccion = data.get("status_seleccion")

            print("Estado recibido:", status_seleccion)  # Debug para verificar el valor recibido

            # Verificamos si el estado recibido es uno de los válidos
            if status_seleccion not in ['aceptado', 'rechazado']:
                return JsonResponse({"success": False, "message": "Estado no válido."})

            # Buscar al aspirante por ID
            aspirante = Aspirante.objects.get(id=aspirante_id)

            # Actualizar el estado solo si es válido
            aspirante.status_seleccion = status_seleccion  # Cambiar solo el estado
            
            # No modificar el campo folio ni otros campos, solo actualizamos status_seleccion
            aspirante.save()

            return JsonResponse({"success": True, "message": f"Estado actualizado a {aspirante.status_seleccion} correctamente."})

        except ObjectDoesNotExist:
            return JsonResponse({"success": False, "message": "Aspirante no encontrado."})
        except json.JSONDecodeError:
            return JsonResponse({"success": False, "message": "Error al procesar los datos."})
        except Exception as e:
            return JsonResponse({"success": False, "message": f"Error inesperado: {str(e)}"})

    return JsonResponse({"success": False, "message": "Método no permitido."})

@login_required
@role_required('CT')
def detalles_aspirante(request, aspirante_id):
    aspirante = get_object_or_404(Aspirante.objects.prefetch_related(
        'datos_personales',
        'datos_personales__documentos',
        'datos_personales__residencia',  # Accediendo a residencia directamente
        'gestion', 
        'banco', 
        'participacion',
    ), id=aspirante_id)

    return render(request, 'home_coordinador/detalles_aspirante.html', {'aspirante': aspirante})

from django.contrib.auth.hashers import make_password
from django.http import JsonResponse
from django.shortcuts import get_object_or_404
import json

def crear_usuario_ajax(request):
    if request.method == "POST":
        try:
            # Recuperar los datos enviados por la solicitud AJAX
            data = json.loads(request.body)
            aspirante_id = data.get('aspirante_id')
            usuario = data.get('usuario')
            rol = data.get('rol')
            contrasenia = data.get('contrasenia')

            # Validación de rol
            valid_roles = [role[0] for role in Usuario._meta.get_field('rol').choices]
            if rol not in valid_roles:
                return JsonResponse({"success": False, "message": "Rol no válido."})

            # Buscar el aspirante relacionado
            aspirante = get_object_or_404(Aspirante, id=aspirante_id)

            if aspirante.usuario and aspirante.usuario.rol == "ASPIRANTE":
                # Actualizar usuario existente
                user = aspirante.usuario
                user.usuario = usuario
                user.contrasenia = contrasenia  # Aunque será encriptada
                user.rol = rol
                user.usuario_rol.username = usuario
                user.usuario_rol.password = make_password(contrasenia)
                user.usuario_rol.role = rol
                user.usuario_rol.save()
                user.save()
            else:
                # Crear un nuevo usuario
                usuario_rol = UsuarioRol.objects.create(
                    username=usuario,
                    role=rol,
                    password=make_password(contrasenia)  # Encriptar contraseña
                )
                user = Usuario.objects.create(
                    usuario_rol=usuario_rol,
                    usuario=usuario,
                    contrasenia=contrasenia,  # Aunque será encriptada
                    rol=rol
                )
                user.save()

                # Asociar el nuevo usuario al aspirante
                aspirante.usuario = user
                aspirante.save()

            # Retornar éxito
            return JsonResponse({"success": True, "message": "Usuario actualizado o creado exitosamente!"})

        except Aspirante.DoesNotExist:
            return JsonResponse({"success": False, "message": "Aspirante no encontrado."})
        except Exception as e:
            return JsonResponse({"success": False, "message": str(e)})

    return JsonResponse({"success": False, "message": "Método no permitido"})

