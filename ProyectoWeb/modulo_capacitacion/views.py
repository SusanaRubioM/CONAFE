from django.shortcuts import render, get_object_or_404, redirect
from django.contrib.auth.decorators import login_required
from .models import CapacitacionInicial
from .forms import CapacitacionForm

@login_required
def lista_capacitaciones(request):
    capacitaciones = CapacitacionInicial.objects.all()
    return render(request, 'modulo_capacitacion/lista_capacitaciones.html', {'capacitaciones': capacitaciones})

@login_required
def crear_capacitacion(request):
    if request.method == 'POST':
        form = CapacitacionForm(request.POST)
        if form.is_valid():
            form.save()
            return redirect('modulo_capacitacion:lista_capacitaciones')
    else:
        form = CapacitacionForm()
    return render(request, 'modulo_capacitacion/crear_capacitacion.html', {'form': form})

@login_required
def editar_capacitacion(request, capacitacion_id):
    capacitacion = get_object_or_404(CapacitacionInicial, id=capacitacion_id)
    if request.method == 'POST':
        form = CapacitacionForm(request.POST, instance=capacitacion)
        if form.is_valid():
            form.save()
            return redirect('modulo_capacitacion:lista_capacitaciones')
    else:
        form = CapacitacionForm(instance=capacitacion)
    return render(request, 'modulo_capacitacion/editar_capacitacion.html', {'form': form, 'capacitacion': capacitacion})

@login_required
def finalizar_capacitacion(request, capacitacion_id):
    capacitacion = get_object_or_404(CapacitacionInicial, id=capacitacion_id)
    if capacitacion.horas_cubiertas >= 240:
        # Marcar como finalizado (puedes agregar un campo 'estado' en el modelo para esto)
        capacitacion.finalizado = True
        capacitacion.save()
        return redirect('modulo_capacitacion:lista_capacitaciones')
    else:
        return render(request, 'modulo_capacitacion/error_finalizacion.html', {'capacitacion': capacitacion})
