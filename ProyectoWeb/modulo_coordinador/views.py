from django.shortcuts import render, get_object_or_404
from login_app.decorators import role_required
from django.contrib.auth.decorators import login_required
from form_app.models import Aspirante
from django.db.models import Prefetch
from django.http import JsonResponse
import json

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

            print("Estado recibido:", status_seleccion)  # Verificar qué valor se recibe en el servidor

            # Verificamos si el estado recibido es uno de los válidos
            if status_seleccion not in ['aceptado', 'pendiente', 'rechazado']:
                return JsonResponse({"success": False, "message": "Estado no válido."})

            # Buscar al aspirante por ID
            aspirante = Aspirante.objects.get(id=aspirante_id)

            if status_seleccion == 'rechazado':
                # Eliminar el UsuarioRol relacionado con el aspirante
                if aspirante.usuario and aspirante.usuario.usuario_rol:
                    aspirante.usuario.usuario_rol.delete()  # Elimina el UsuarioRol asociado al usuario
                    aspirante.usuario.delete()  # Eliminar también el Usuario si es necesario
                return JsonResponse({"success": True, "message": "Aspirante y sus datos eliminados correctamente."})

            # Si el estado es 'aceptado' o 'pendiente', actualizar el estado del aspirante
            aspirante.status_seleccion = status_seleccion
            aspirante.save()

            return JsonResponse({"success": True, "message": "Estado actualizado correctamente."})

        except Aspirante.DoesNotExist:
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
