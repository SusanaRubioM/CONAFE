from django.shortcuts import render, redirect, get_object_or_404
from login_app.decorators import role_required
from django.contrib.auth.decorators import login_required
from modulo_apec.models import ServicioEducativo
from django.db.models import Count, Avg, Q
from django.contrib import messages
from django.http import JsonResponse
from modulo_dot.models import Usuario
from modulo_apec.models import Comunidad
from modulo_dpe.models import PromocionesAlumnos, Grupo
@login_required
@role_required("DPE")
def view_home_dpe(request):
    return render(request, 'home_dpe/home_dpe.html')

@login_required
@role_required("DPE")
def dashboard_vacantes_dpe(request):
    # Filtros disponibles
    estados = ServicioEducativo.objects.values_list('nombre_estado', flat=True).distinct()
    regiones = ServicioEducativo.objects.values_list('nombre_region', flat=True).distinct()
    comunidades = ServicioEducativo.objects.values_list('nombre_comunidad', flat=True).distinct()

    # Captura de filtros
    estado_filter = request.GET.get('estado', None)
    region_filter = request.GET.get('region', None)
    comunidad_filter = request.GET.get('comunidad', None)
    status_filter = request.GET.get('status', 'pendiente')

    # Filtrar los servicios educativos
    servicios = ServicioEducativo.objects.all()
    if estado_filter:
        servicios = servicios.filter(nombre_estado=estado_filter)
    if region_filter:
        servicios = servicios.filter(nombre_region=region_filter)
    if comunidad_filter:
        servicios = servicios.filter(nombre_comunidad=comunidad_filter)
    if status_filter:
        servicios = servicios.filter(status=status_filter)

    return render(request, 'home_dpe/dashboard_vacantes_dpe.html', {
        'servicios': servicios,
        'estados': estados,
        'regiones': regiones,
        'comunidades': comunidades
    })


@login_required
@role_required("DPE")
def estadisticas_dashboard(request): 
    # Estadísticas principales
    estadisticas = {
        'total_vacantes': ServicioEducativo.objects.count(),
        'vacantes_por_estado': ServicioEducativo.objects.values('nombre_estado').annotate(total=Count('id')),
        'vacantes_por_nivel': ServicioEducativo.objects.values('nivel_escolar').annotate(total=Count('id')),
        'promedio_solicitudes': ServicioEducativo.objects.aggregate(Avg('cantidad_solicitudes'))['cantidad_solicitudes__avg'] or 0,
    }

    # Cálculo de alumnos aprobados y reprobados
    total_alumnos = PromocionesAlumnos.objects.count()
    total_aprobados = PromocionesAlumnos.objects.filter(calfFinal__gte=70).count()  # Umbral de aprobación
    total_reprobados = total_alumnos - total_aprobados  # Realizamos la resta aquí
    porcentaje_aprobados = (total_aprobados / total_alumnos) * 100 if total_alumnos > 0 else 0

    # Figuras educativas y alumnos por comunidad
    figuras_educativas = Usuario.objects.filter(rol__in=["EC", "ECAR", "ECA"]).values('rol').annotate(total=Count('id'))
    alumnos_por_comunidad = Comunidad.objects.values('nombre_comunidad').annotate(total_alumnos=Count('usuario__id'))

    # Agregar estadísticas calculadas
    estadisticas.update({
        'figuras_educativas': list(figuras_educativas),
        'alumnos_por_comunidad': list(alumnos_por_comunidad),
        'porcentaje_aprobados': porcentaje_aprobados,
        'total_alumnos': total_alumnos,
        'total_aprobados': total_aprobados,
        'total_reprobados': total_reprobados,  # Agregar al contexto
    })

    return render(request, 'home_dpe/estadisticas_dashboard.html', {
        'estadisticas': estadisticas
    })

@login_required
@role_required("DPE")
def actualizar_estado_servicio(request, servicio_id):
    servicio = get_object_or_404(ServicioEducativo, id=servicio_id)

    if request.method == "POST":
        accion = request.POST.get('accion')

        if accion == 'aprobar':
            servicio.status = 'aprobado'
            ServicioEducativo.objects.create(
                comunidad_servicio=servicio.comunidad_servicio,
                nombre_estado=servicio.nombre_estado,
                nombre_region=servicio.nombre_region,
                nombre_microregion=servicio.nombre_microregion,
                nombre_comunidad=servicio.nombre_comunidad,
                clave_centro_trabajo=servicio.clave_centro_trabajo,
                nombre_escuela=servicio.nombre_escuela,
                tipo_sede=servicio.tipo_sede,
                tipo_servicio=servicio.tipo_servicio,
                nivel_escolar=servicio.nivel_escolar,
                periodo_servicio=servicio.periodo_servicio,
                rol_vacante=servicio.rol_vacante,
                status='pendiente'
            )
            messages.success(request, 'Servicio aprobado y nueva vacante creada exitosamente.')
        elif accion == 'rechazar':
            servicio.status = 'rechazado'
            messages.warning(request, 'Servicio rechazado exitosamente.')

        servicio.save()

        # Respuesta para AJAX
        if request.headers.get('X-Requested-With') == 'XMLHttpRequest':
            return JsonResponse({'status': 'success', 'nuevo_estado': servicio.status})
        
        return redirect('modulo_dpe:vacantes_dashboard')

    return JsonResponse({'status': 'error', 'mensaje': 'Método no permitido'}, status=405)