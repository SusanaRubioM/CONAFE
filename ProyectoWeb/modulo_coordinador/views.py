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
from django.contrib import messages
from modulo_dot.views import dashboard_vacantes as original_dashboard_vacantes
from modulo_apec.models import ServicioEducativo,Estado, Municipio
from modulo_apec.forms import ObservacionForm
from modulo_dpe.models import Reporte
from modulo_DECB.models import CalendarEvent  # Importar el modelo de eventos del módulo DECB
from login_app.models import Statuses

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
            return redirect('coordinador_home:vacante_asignacion_ct', servicio_id=servicio.id)
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

        messages.success(request, "¡Operación Exitosa! Los cambios han sido guardados correctamente.")

    return render(
        request,
        'home_coordinador/vacante_asignacion_ct.html',
        {'servicio': servicio, 'usuarios': usuarios, 'observacion': observacion}
    )

def exito_view_ct(request):
    return render(request, 'home_coordinador/mensaje_exito_ct.html')

# aqui termina



"""
@login_required
@role_required('CT')
def dashborard_equipamiento(request):
    # Filtrar reportes según la categoría seleccionada (si es que se ha seleccionado alguna)
    categoria = request.GET.get('categoria', '')  # Obtiene la categoría desde el query string
    if categoria:
        # Filtra reportes por categoría y estado "pendiente"
        reportes = Reporte.objects.filter(categoria=categoria, estado='pendiente')
    else:
        # Si no se filtra por categoría, solo muestra los reportes con estado "pendiente"
        reportes = Reporte.objects.filter(estado='pendiente')  # Solo reportes pendientes

    return render(request, 'home_coordinador/dashboard_equipo_pdf.html', {'reportes': reportes})

"""
# menu reportes 
@login_required
@role_required('CT')
def menu_reportes_ct(request):
    return render(request, 'home_coordinador/dashboard_equipo_pdf.html')

@login_required
@role_required('CT')
def dashboard_equipamiento(request):
    # Filtrar reportes según la categoría seleccionada (si es que se ha seleccionado alguna)
    categoria = request.GET.get('categoria', '')  # Obtiene la categoría desde el query string
    if categoria:
        reportes = Reporte.objects.filter(categoria=categoria)  # Filtra reportes por categoría
    else:
        reportes = Reporte.objects.all()  # Si no se filtra, muestra todos los reportes

    return render(request, 'home_coordinador/dashboard_equipo_pdf.html', {'reportes': reportes})

@login_required
@role_required('CT')
def dashboard_capacitacion_pdf(request):
    # Filtrar reportes según la categoría "capacitación"
    categoria = 'capacitación'  # Definir directamente la categoría
    reportes = Reporte.objects.filter(categoria=categoria)

    return render(request, 'home_coordinador/dashboard_capacitacion_pdf.html', {'reportes': reportes})

@login_required
@role_required('CT')
def dashboard_seguim_pdf(request):
    # Filtrar reportes según la categoría "seguimiento"
    categoria = 'seguimiento'  # Definir directamente la categoría
    reportes = Reporte.objects.filter(categoria=categoria)

    return render(request, 'home_coordinador/dashboard_seguim_pdf.html', {'reportes': reportes})


@login_required
@role_required('CT')
def validar_rechazar_reporte(request, reporte_id):
    # Obtener el reporte
    try:
        reporte = Reporte.objects.get(id=reporte_id)
    except Reporte.DoesNotExist:
        return redirect('coordinador_home:dashboard_equipamiento')  # Si no existe el reporte, redirige

    # Obtener la acción (validar o rechazar) desde el formulario
    if request.method == "POST":
        accion = request.POST.get('accion')

        if accion == 'validar':
            reporte.estado = 'validado'
        elif accion == 'rechazar':
            reporte.estado = 'rechazado'

        # Guardamos el reporte con el nuevo estado
        reporte.save()

    # Filtrar nuevamente los reportes para cargar los actualizados
    categoria = request.GET.get('categoria', '')  # Reemplazar por el filtro actual si existe
    if categoria:
        reportes = Reporte.objects.filter(categoria=categoria)  # Filtra reportes por categoría
    else:
        reportes = Reporte.objects.all()  # Si no se filtra, muestra todos los reportes

    # Redirigir con los reportes actualizados
    return render(request, 'home_coordinador/dashboard_equipo_pdf.html', {'reportes': reportes})
def ajax_aspirante_status(request, aspirante_id):
    if request.method == "POST":
        try:
            # Obtener los datos del cuerpo de la solicitud en formato JSON
            data = json.loads(request.body)
            status_seleccion = data.get("status_seleccion")

            # Verificar que el estado recibido sea válido
            if status_seleccion not in ['aceptado', 'rechazado']:
                return JsonResponse({"success": False, "message": "Estado no válido."})

            # Buscar al aspirante por ID
            aspirante = Aspirante.objects.get(id=aspirante_id)

            # Actualizar el estado del aspirante
            aspirante.status_seleccion = status_seleccion
            aspirante.save()

            return JsonResponse({"success": True, "message": f"Estado actualizado a {status_seleccion} correctamente."})

        except ObjectDoesNotExist:
            return JsonResponse({"success": False, "message": "Aspirante no encontrado."})
        except json.JSONDecodeError:
            return JsonResponse({"success": False, "message": "Error al procesar los datos."})
        except Exception as e:
            return JsonResponse({"success": False, "message": f"Error inesperado: {str(e)}"})

    return JsonResponse({"success": False, "message": "Método no permitido."})

from form_app.models import Participacion

def crear_usuario_ajax(request):
    if request.method == "POST":
        try:
            # Recuperar los datos enviados por la solicitud AJAX
            data = json.loads(request.body)
            aspirante_id = data.get('aspirante_id')

            # Buscar el aspirante relacionado
            aspirante = get_object_or_404(Aspirante, id=aspirante_id)
            # Asignación fija del rol
            rol = aspirante.participacion.programa_participacion # Rol fijo para todos los usuarios

            # Usamos el folio del aspirante como el nombre de usuario
            usuario = aspirante.folio
            contrasenia = aspirante.datos_personales.curp  # CURP como contraseña

            # Validar que el CURP no esté vacío
            if not contrasenia:
                return JsonResponse({"success": False, "message": "CURP del aspirante no disponible."})

            # Verificar si el aspirante ya tiene un usuario asociado
            if aspirante.usuario:
                # Si el aspirante ya tiene un usuario asociado, actualizamos ese usuario
                user = aspirante.usuario
                user.usuario = usuario
                user.contrasenia = contrasenia  # Aunque será encriptada
                user.rol = rol
                
                # Actualizar el usuario_rol relacionado
                user.usuario_rol.username = usuario
                user.usuario_rol.password = make_password(contrasenia)  # Encriptamos la contraseña
                user.usuario_rol.role = rol
                user.usuario_rol.is_active = True
                user.usuario_rol.save()
                user.save()

                # Aquí actualizamos o asignamos el estado de 'Capacitación' al usuario
                status, created = Statuses.objects.get_or_create(usuario=user)
                status.status = 'capacitacion'  # Asignamos el nuevo estado
                status.save()
            else:
                # Si el aspirante no tiene un usuario, creamos uno nuevo
                usuario_rol = UsuarioRol.objects.create(
                    username=usuario,
                    role=rol,
                    password=make_password(contrasenia)  # Encriptamos la contraseña
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

            return JsonResponse({"success": True, "message": "Usuario creado exitosamente!"})

        except Aspirante.DoesNotExist:
            return JsonResponse({"success": False, "message": "Aspirante no encontrado."})
        except Exception as e:
            return JsonResponse({"success": False, "message": str(e)})

    return JsonResponse({"success": False, "message": "Método no permitido"})




from modulo_coordinador.models import ConveniosFiguras

@login_required
@role_required('CT')
def dashboard_convenio_view(request):
    # Obtener el estado del filtro
    estado = request.GET.get('estado', '')
    
    # Consultar convenios con información relacionada
    convenios = ConveniosFiguras.objects.select_related(
        'usuario',
        'usuario__aspirante',
        'usuario__aspirante__datos_personales'
    )
    
    if estado:
        convenios = convenios.filter(estado_convenio=estado)
    
    # Crear lista de datos completos
    convenios_data = []
    for convenio in convenios:
        aspirante = getattr(convenio.usuario, 'aspirante', None)
        datos_personales = getattr(aspirante, 'datos_personales', None) if aspirante else None
        
        convenio_info = {
            'convenio': convenio,
            'folio_aspirante': aspirante.folio if aspirante else 'No disponible',
            'nombre_completo': str(aspirante) if aspirante else 'No disponible',
            'datos_personales': datos_personales
        }
        convenios_data.append(convenio_info)
        
    context = {
        'convenios_data': convenios_data,
    }
    
    return render(request, 'dashboards/dashboards_convenios.html', context)

@login_required
@role_required('CT')
def actualizar_estado_convenio(request, convenio_id):
    if request.method == "POST":
        convenio = get_object_or_404(ConveniosFiguras, id=convenio_id)
        accion = request.POST.get('accion')
        
        if accion == 'aprobar':
            convenio.estado_convenio = 'Aprobado'
            messages.success(request, 'Convenio aprobado exitosamente.')
        elif accion == 'rechazar':
            convenio.estado_convenio = 'Rechazado'
            messages.success(request, 'Convenio rechazado.')
            
        convenio.save()
        
    return redirect('coordinador_home:dashboard_convenios')







# GIS

#def dashboard_gestion_RMR(request):
#    servicios = ServicioEducativo.objects.all()
#    return render(request, 'home_dot/dashboard_vacantes.html', {'servicios': servicios})


def dashboard_gestion_RMR(request):
    estados = Estado.objects.all()
    #return render(request, 'gis/index.html', {'estados': estados})
    return render(request, 'gis/index.html', {'estados': estados})

def dashboard_gestion_estado(request):
    municipios = Municipio.objects.all()
    return render(request, 'gis/municipio.html', {'municipios': municipios})