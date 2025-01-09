from django.shortcuts import render, get_object_or_404, redirect
from django.contrib.auth.decorators import login_required
from django.contrib import messages
from .models import CapacitacionInicial
from .forms import CapacitacionForm

@login_required
def lista_capacitaciones(request):
    """Vista para listar todas las capacitaciones iniciales"""
    capacitaciones = CapacitacionInicial.objects.all()
    return render(request, 'modulo_capacitacion/lista_capacitaciones.html', {'capacitaciones': capacitaciones})

@login_required
def crear_capacitacion(request):
    """Vista para crear una nueva capacitación"""
    if request.method == 'POST':
        form = CapacitacionForm(request.POST)
        if form.is_valid():
            form.save()
            messages.success(request, 'La capacitación se ha creado exitosamente.')
            return redirect('modulo_capacitacion:lista_capacitaciones')
        else:
            messages.error(request, 'Hubo un error al crear la capacitación. Por favor, revisa los datos.')
    else:
        form = CapacitacionForm()
    
    return render(request, 'modulo_capacitacion/crear_capacitacion.html', {'form': form})

@login_required
def editar_capacitacion(request, capacitacion_id):
    """Vista para editar una capacitación existente"""
    capacitacion = get_object_or_404(CapacitacionInicial, id=capacitacion_id)
    
    if request.method == 'POST':
        form = CapacitacionForm(request.POST, instance=capacitacion)
        if form.is_valid():
            form.save()
            messages.success(request, 'La capacitación se ha actualizado exitosamente.')
            return redirect('modulo_capacitacion:lista_capacitaciones')
        else:
            messages.error(request, 'Hubo un error al actualizar la capacitación. Por favor, revisa los datos.')
    else:
        form = CapacitacionForm(instance=capacitacion)
    
    return render(request, 'modulo_capacitacion/editar_capacitacion.html', {'form': form, 'capacitacion': capacitacion})

@login_required
def finalizar_capacitacion(request, capacitacion_id):
    """Vista para finalizar una capacitación si las horas cubiertas son >= 240"""
    capacitacion = get_object_or_404(CapacitacionInicial, id=capacitacion_id)
    
    if capacitacion.horas_cubiertas >= 240:
        # Agregar un campo 'finalizado' en el modelo para marcar la capacitación como finalizada
        capacitacion.finalizado = True
        capacitacion.save()
        messages.success(request, 'La capacitación ha sido finalizada correctamente.')
        return redirect('modulo_capacitacion:lista_capacitaciones')
    else:
        messages.error(request, 'No es posible finalizar la capacitación porque las horas cubiertas son menores a 240.')
        return render(request, 'modulo_capacitacion/error_finalizacion.html', {'capacitacion': capacitacion})
