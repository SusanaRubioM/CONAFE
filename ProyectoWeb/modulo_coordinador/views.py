from django.shortcuts import render, get_object_or_404, redirect
from login_app.decorators import role_required
from django.contrib.auth.decorators import login_required
from form_app.models import Aspirante, Usuario
from django.contrib.auth.hashers import make_password
from login_app.models import UsuarioRol
from modulo_dot.models import DatosPersonales 
from django.db.models import Prefetch
from django.http import JsonResponse, HttpResponse
import json
from django.utils import timezone
from django.core.exceptions import ObjectDoesNotExist
from modulo_dot.views import dashboard_vacantes as original_dashboard_vacantes
from modulo_apec.models import ServicioEducativo
from modulo_apec.forms import ObservacionForm
@login_required
@role_required('CT')
def empleado_view(request):
    # Lógica específica para el coordinador territorial
    return render(request, 'home_coordinador/home_coordinador.html')

@login_required
@role_required('CT')
def dashboard_aspirantes_rechazados(request):
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
        "home_coordinador/dashboard_aspirante_rechazados.html",
        {"aspirantes": aspirantes},
    )
@login_required
@role_required('CT')
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

@login_required
@role_required('CT')
def dashboard_aspirantes_aceptados(request):
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
        "home_coordinador/dashboard_aspirante_aceptados.html",
        {"aspirantes": aspirantes},
    )
@login_required
@role_required('CT')
def dashboard_aspirantes_aceptados_eca_ecar(request):
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
        "home_coordinador/dashboard_eca_aceptados.html",
        {"aspirantes": aspirantes},
    )
@login_required
@role_required('CT')
def dashboard_aspirantes_rechazados_eca_ecar(request):
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
        "home_coordinador/dashboard_eca_rechazados.html",
        {"aspirantes": aspirantes},
    )

@login_required
@role_required('CT')
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

@login_required
@role_required('CT')
def dashboard_figura_educativa(request):
    """
    Vista para mostrar el dashboard con todos los educadores filtrados por roles específicos.
    """
    # Filtrar los educadores según los roles permitidos
    empleados = (
        Aspirante.objects
        .select_related(
            "datos_personales",
            "datos_personales__documentos",  # Relación de DocumentosPersonales
            "residencia",
            "participacion",
            "gestion",
            "usuario",
            "usuario__statuses",
        )
        .filter(usuario__rol__in=["EC", "ECA", "ECAR"])  # Filtrar por roles específicos
    )

    # Renderizar el template con los datos filtrados
    return render(
        request, 
        "home_coordinador/dashboard_figuras.html", 
        {"empleados": empleados}  # Cambié el nombre a empleados para que coincida con el template
    )


@login_required
@role_required("CT")
def detalles_educador(request, empleado_id):
    """
    Vista para ver los detalles de un empleado en específico.
    """
    # Obtener el objeto DatosPersonales asociado al usuario con el id proporcionado
    empleado = get_object_or_404(DatosPersonales.objects.select_related("documentos"), usuario__id=empleado_id)
    
    # Pasar el objeto empleado a la plantilla
    return render(request, "home_coordinador/detalles_educador.html", {"empleado": empleado})


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


#Modulo observaciones

@login_required
@role_required('CT')
def observaciones_view(request):
    servicios = ServicioEducativo.objects.all()

    if request.method == 'POST':
        servicio_id = request.POST.get('servicio_id')
        try:
            servicio = ServicioEducativo.objects.get(id=servicio_id)
        except ServicioEducativo.DoesNotExist:
            return HttpResponse("Servicio no encontrado", status=404)

        form = ObservacionForm(request.POST)
        if form.is_valid():
            observacion = form.save(commit=False)
            observacion.servicio_educativo = servicio
            observacion.fecha_creacion = timezone.now()
            observacion.save()

            # Redirigir a la página de asignación de vacantes
            return redirect('home_coordinador:asignacion_vacantes', servicio_id=servicio.id)
        else:
            return HttpResponse("Formulario no válido", status=400)

    return render(request, 'home_coordinador/dashboard_vacantes_ct.html', {'servicios': servicios})

# Customizing the original function to add new behavior
def dashboard_vacantes_ct(request):
    # Example: Logging the request before processing
    print("Request received for dashboard_vacantes")
    return original_dashboard_vacantes(request)

@login_required
@role_required('CT')
def dashboard_asignar(request):
    servicios = ServicioEducativo.objects.all()

    if request.method == 'POST':
        servicio_id = request.POST.get('servicio_id')
        try:
            servicio = ServicioEducativo.objects.get(id=servicio_id)
        except ServicioEducativo.DoesNotExist:
            return HttpResponse("Servicio no encontrado", status=404)

        form = ObservacionForm(request.POST)
        if form.is_valid():
            observacion = form.save(commit=False)
            observacion.servicio_educativo = servicio
            observacion.fecha_creacion = timezone.now()
            observacion.save()

            # Redirigir a la página de asignación de vacantes
            return redirect('coordinador_home:asignacion_vacantes_ct', servicio_id=servicio.id)
        else:
            return HttpResponse("Formulario no válido", status=400)

    return render(request, 'home_coordinador/dashboard_vacantes_ct.html', {'servicios': servicios})

from modulo_apec.models import Observacion

@login_required
@role_required('CT')
def asignacion_vacantes_view_ct(request, servicio_id):
    servicio = get_object_or_404(ServicioEducativo, id=servicio_id)

    # Consulta optimizada con el nombre correcto del campo relacionado
    usuarios = Usuario.objects.filter(rol__in=['EC', 'ECA', 'ECAR']).select_related('datospersonales', 'aspirante__residencia')

    # Obtención de la observación asociada al servicio educativo
    observacion = Observacion.objects.filter(servicio_educativo=servicio).first()

    if request.method == 'POST':
        candidatos_ids = request.POST.getlist('candidatos')
        candidatos = Usuario.objects.filter(id__in=candidatos_ids).select_related('datospersonales', 'aspirante__residencia')

        comentario = request.POST.get('comentario')
        rol = request.POST.get('rol')
        ciclo = request.POST.get('ciclo')

        if observacion:
            observacion.comentario = comentario if comentario else observacion.comentario
            observacion.save()
        else:
            observacion = Observacion.objects.create(
                servicio_educativo=servicio,
                fecha_creacion=timezone.now(),
                comentario=comentario,
            )

        servicio.rol_vacante = rol if rol else 'NP'
        servicio.periodo_servicio = ciclo if ciclo else 'Sin asignar'
        servicio.save()

        if candidatos:
            observacion.candidatos.set(candidatos)
            observacion.save()

        return redirect('coordinador_home:asignacion_vacantes_ct', servicio_id=servicio.id)

    return render(
        request,
        'home_coordinador/vacante_asignacion_ct.html',
        {'servicio': servicio, 'usuarios': usuarios, 'observacion': observacion}
    )

def exito_view_ct(request):
    return render(request, 'home_coordinador/mensaje_exito_ct.html')

# aqui termina

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

