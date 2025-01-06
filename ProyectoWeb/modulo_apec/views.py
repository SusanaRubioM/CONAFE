from django.shortcuts import render, redirect, get_object_or_404
from django.contrib.auth.decorators import login_required
from login_app.decorators import role_required
from .models import ServicioEducativo, Observacion
from .forms import ObservacionForm
from django.utils import timezone
from django.contrib import messages
from django.http import HttpResponse
from modulo_dot.models import Usuario

@login_required
@role_required('APEC')
def home_view(request):
    return render(request, 'home_apec/home_apec.html')


@login_required
@role_required('APEC')
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
            return redirect('modulo_apec:asignacion_vacantes', servicio_id=servicio.id)
        else:
            return HttpResponse("Formulario no válido", status=400)

    return render(request, 'home_apec/dashboard_vacantes_apec.html', {'servicios': servicios})

@login_required
@role_required('APEC')
def asignacion_vacantes_view(request, servicio_id):
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

        
        return redirect('modulo_apec:view_exito')

    return render(
        request,
        'home_apec/asignacion_vacantes.html',
        {'servicio': servicio, 'usuarios': usuarios}
    )

def exito_view(request):
    return render(request, 'home_apec/mensaje_exito.html')