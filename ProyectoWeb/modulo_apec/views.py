from django.shortcuts import render, redirect
from django.contrib.auth.decorators import login_required
from login_app.decorators import role_required
from .models import ServicioEducativo, Observacion
from .forms import ObservacionForm
from django.utils import timezone
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
    try:
        servicio = ServicioEducativo.objects.get(id=servicio_id)
    except ServicioEducativo.DoesNotExist:
        return HttpResponse("Servicio no encontrado", status=404)

    usuarios = Usuario.objects.filter(rol='EC')  # Obtener usuarios con rol de EC

    if request.method == 'POST':
        candidatos_ids = request.POST.getlist('candidatos')
        candidatos = Usuario.objects.filter(id__in=candidatos_ids)

        # Guardar los candidatos sugeridos en la observación
        observacion = Observacion.objects.create(
            servicio_educativo=servicio,
            fecha_creacion=timezone.now(),
            comentario=request.POST.get('comentario'),
        )
        observacion.candidatos.set(candidatos)
        observacion.save()

        # Redirigir a la lista de observaciones
        return redirect('modulo_apec:observaciones')

    return render(
        request,
        'home_apec/asignacion_vacantes.html',
        {'servicio': servicio, 'usuarios': usuarios}
    )
