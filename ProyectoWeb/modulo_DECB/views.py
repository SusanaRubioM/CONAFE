from django.shortcuts import render, redirect
from .models import PaymentSchedule, PaymentHistory
from login_app.models import UsuarioRol
from django.contrib.auth.decorators import login_required
from .forms import PaymentAssignmentForm
from django.contrib.auth.decorators import login_required
from .models import PaymentSchedule
from .forms import PaymentAssignmentForm
from .models import CalendarEvent
from .forms import CalendarEventForm
from django.contrib.auth.decorators import login_required


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
            return redirect('modulo_DECB:visualizar_calendario')
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
def asignar_pagos(request):
    if request.method == 'POST':
        form = PaymentAssignmentForm(request.POST)
        if form.is_valid():
            payment_schedule = form.save(commit=False)
            payment_schedule.assigned_by = request.user
            payment_schedule.save()
            return redirect('modulo_DECB:visualizar_calendario')  # Cambiado a visualizar_calendario
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

