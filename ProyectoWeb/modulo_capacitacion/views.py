from django.shortcuts import render, redirect, get_object_or_404
from django.contrib import messages
from django.http import JsonResponse, HttpResponse
from django.utils import timezone
from .forms import CapacitacionInicialForm
from modulo_coordinador.forms import ObservacionForm
from .models import VacanteAsignada
from modulo_dot.models import Usuario, DatosPersonales, ServicioEducativo
import logging

logger = logging.getLogger(__name__)

def lista_vacantes_asignadas(request):
    capacitaciones = VacanteAsignada.objects.select_related(
        'ecar__datospersonales',
        'eca__datospersonales',
        'ec__datospersonales'
    ).all()
    return render(request, 'modulo_capacitacion/lista_capacitaciones.html', {
        'capacitaciones': capacitaciones
    })

def crear_asignacion(request):
    if request.method == 'POST':
        form = CapacitacionInicialForm(request.POST)
        if form.is_valid():
            capacitacion = form.save()
            messages.success(request, 'Capacitación registrada exitosamente.')
            return redirect('modulo_capacitacion:lista_capacitaciones')
        else:
            messages.error(request, 'Por favor corrija los errores en el formulario.')
    else:
        form = CapacitacionInicialForm()

    # Recuperar todos los servicios educativos para pasarlos al template
    servicios = ServicioEducativo.objects.all()

    # Renderizar el template y pasar tanto el formulario como los servicios
    return render(request, 'modulo_capacitacion/crear_capacitacion.html', {
        'form': form,
        'servicios': servicios,  # Pasar los servicios al template
    })

def obtener_datos_usuario(request, usuario_id):
    try:
        usuario = Usuario.objects.get(id=usuario_id)
        response_data = {'id': usuario.id, 'rol': usuario.id, 'nombre_completo': 'Sin datos personales'}
        
        try:
            datos_personales = DatosPersonales.objects.get(usuario=usuario)
            response_data['nombre_completo'] = f"{datos_personales.nombre} {datos_personales.apellidopa} {datos_personales.apellidoma}".strip()
        except DatosPersonales.DoesNotExist:
            logger.warning(f"No se encontraron datos personales para el usuario {usuario_id}")
        
        return JsonResponse(response_data)
    except Usuario.DoesNotExist:
        logger.error(f"Usuario no encontrado: {usuario_id}")
        return JsonResponse({'error': 'Usuario no encontrado'}, status=404)
    except Exception as e:
        logger.error(f"Error inesperado: {str(e)}")
        return JsonResponse({'error': 'Error interno del servidor'}, status=500)

def finalizar_asignacion(request, capacitacion_id):
    capacitacion = get_object_or_404(VacanteAsignada, id=capacitacion_id)
    if capacitacion.estado != 'completada':
        capacitacion.estado = 'completada'
        capacitacion.save()
        messages.success(request, 'Capacitación finalizada exitosamente.')
    else:
        messages.warning(request, 'La capacitación ya estaba marcada como completada.')
    return redirect('modulo_capacitacion:lista_capacitaciones')

def dashboard_asignar(request):
    # Trae todos los servicios educativos
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

def editar_asignacion(request, capacitacion_id):
    capacitacion = get_object_or_404(VacanteAsignada, id=capacitacion_id)
    
    if request.method == 'POST':
        form = CapacitacionInicialForm(request.POST, instance=capacitacion)
        if form.is_valid():
            form.save()
            messages.success(request, 'Capacitación actualizada exitosamente.')
            return redirect('modulo_capacitacion:lista_capacitaciones')
    else:
        form = CapacitacionInicialForm(instance=capacitacion)
    
    return render(request, 'modulo_capacitacion/editar_capacitacion.html', {
        'form': form,
        'capacitacion': capacitacion
    })
