from django.shortcuts import render, redirect, get_object_or_404
from .models import PaymentSchedule, PaymentHistory
from login_app.models import UsuarioRol
from django.contrib.auth.decorators import login_required
from django.contrib import messages
from .forms import PaymentAssignmentForm
from django.contrib.auth.decorators import login_required
from .models import PaymentSchedule
from .forms import PaymentAssignmentForm
from .models import CalendarEvent, PaymentStatus
from .forms import CalendarEventForm
from django.contrib.auth.decorators import login_required
from datetime import datetime


@login_required
def historial_pagos(request):
    pagos = PaymentSchedule.objects.all()
    return render(request, 'modulo_DECB/payment_schedule_list.html', {'schedules': pagos})


def calendario_eventos(request):
    eventos = CalendarEvent.objects.all()
    return render(request, 'modulo_DECB/calendario_eventos.html', {'eventos': eventos})

@login_required
def visualizar_calendario(request):
    eventos = CalendarEvent.objects.all().order_by('date')
    return render(request, 'modulo_DECB/calendario.html', {'eventos': eventos})

@login_required
def agregar_evento(request):
    if request.method == 'POST':
        form = CalendarEventForm(request.POST)
        if form.is_valid():
            form.save()
            return redirect('modulo_DECB:calendario_eventos')
    else:
        form = CalendarEventForm()
    return render(request, 'modulo_DECB/agregar_evento.html', {'form': form})

@login_required
def home_decb(request):
    return render(request, 'modulo_DECB/home_decb.html')

@login_required
def visualizar_calendario_decb(request):
    pagos = PaymentSchedule.objects.filter(assigned_by=request.user).order_by('payment_date')
    return render(request, 'modulo_DECB/visualizar_calendario.html', {'pagos': pagos})

@login_required
def visualizar_calendario(request):
    pagos = PaymentSchedule.objects.filter(assigned_by=request.user)
    return render(request, 'modulo_DECB/visualizar_calendario.html', {'pagos': pagos})

@login_required
def visualizar_pagos(request):
    pagos = PaymentSchedule.objects.all().order_by('payment_date')
    return render(request, 'modulo_DECB/visualizar_pagos.html', {'pagos': pagos})



@login_required
def asignar_pagos(request):
    if request.method == 'POST':
        form = PaymentAssignmentForm(request.POST)
        if form.is_valid():
            payment_schedule = form.save(commit=False)
            payment_schedule.assigned_by = request.user  # El usuario que está asignando el pago

            # Verificar que el tipo de pago esté en los tipos permitidos
            allowed_payment_types = [
                'movilidad', 'hospedaje', 'continuidad', 'conectividad',
                'vestuario', 'atencion_medica', 'fin_de_año', 'fallecimiento'
            ]
            
            # Verificar que el tipo de pago del formulario esté en la lista de tipos permitidos
            if payment_schedule.payment_type not in allowed_payment_types:
                # Si no está en la lista, mostrar un error (opcional, según tu lógica de negocio)
                form.add_error('payment_type', 'Tipo de pago no permitido.')
                return render(request, 'modulo_DECB/asignar_pagos.html', {'form': form})
            
            # Asignar la fecha de pago a la fecha actual
            payment_schedule.payment_date = datetime.now()

            # Guardar el pago en la base de datos
            payment_schedule.save()
            return redirect('modulo_DECB:visualizar_calendario')  # Redirigir a la vista del calendario
    else:
        form = PaymentAssignmentForm()

    return render(request, 'modulo_DECB/asignar_pagos.html', {'form': form})


@login_required
def historial_pagos(request):
    pagos = PaymentHistory.objects.filter(payment_schedule__assigned_by=request.user).order_by('-fecha')
    return render(request, 'modulo_DECB/historial_pagos.html', {'pagos': pagos})

@login_required
def historial_calendario(request):
    fechas = PaymentSchedule.objects.filter(assigned_by=request.user).order_by('-payment_date')
    return render(request, 'modulo_DECB/historial_calendario.html', {'fechas': fechas})

@login_required
def mark_payment_completed(request, payment_id):
    if request.method == 'POST':
        payment = get_object_or_404(PaymentSchedule, id=payment_id)
        
        # Crear o obtener el estado del pago
        payment_status, created = PaymentStatus.objects.get_or_create(payment=payment)
        
        comments = request.POST.get('comments', '')
        evidence = request.FILES.get('evidence')
        
        if evidence:
            payment_status.evidence = evidence
            
        payment_status.mark_as_completed(request.user, comments)
        
        messages.success(request, "Pago marcado como completado exitosamente.")
        return redirect('modulo_DECB:visualizar_pagos')
        
    return redirect('modulo_DECB:visualizar_pagos')