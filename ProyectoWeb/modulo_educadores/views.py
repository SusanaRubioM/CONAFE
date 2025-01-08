from django.shortcuts import render, get_object_or_404, redirect
from django.http import JsonResponse, HttpResponseRedirect
from django.contrib.auth.decorators import login_required
from django.contrib.auth import login
from modulo_DECB.models import PaymentSchedule
from login_app.models import UsuarioRol
from .forms import ConfirmarRecepcionForm

@login_required
def confirmar_recepcion(request, payment_id):
    """
    Confirma la recepción de un pago asignado al educador, cambiando su estado a 'recibido'
    y guardando la firma.
    """
    payment = get_object_or_404(PaymentSchedule, id=payment_id, assigned_to=request.user)

    if request.method == 'POST':
        # Reemplazo de `is_ajax`
        if request.headers.get('X-Requested-With') == 'XMLHttpRequest':  # Verifica si la solicitud es AJAX
            form = ConfirmarRecepcionForm(request.POST, request.FILES, instance=payment)
            if form.is_valid():
                payment.status = 'recibido'
                form.save()
                return JsonResponse({'success': True, 'message': 'Recepción confirmada con firma.'})
            else:
                return JsonResponse({'success': False, 'errors': form.errors})

    # Si no es POST, carga el formulario
    form = ConfirmarRecepcionForm(instance=payment)
    return render(request, 'modulo_educadores/confirmar_recepcion.html', {'form': form, 'payment': payment})

@login_required
def redireccionar_por_rol(request):
    """
    Redirige al usuario a su página de inicio correspondiente según su rol.
    """
    try:
        usuario_rol = UsuarioRol.objects.get(user=request.user)

        if usuario_rol.role == 'APEC':
            return redirect('modulo_educadores:home_apec')
        elif usuario_rol.role == 'ECA':
            return redirect('modulo_educadores:home_eca')
        elif usuario_rol.role == 'ECAR':
            return redirect('modulo_educadores:home_ecar')
        elif usuario_rol.role == 'EC':
            return redirect('modulo_educadores:home_ec')
        else:
            return redirect('modulo_educadores:default_home')  # Página general si no hay rol
    except UsuarioRol.DoesNotExist:
        # Si el usuario no tiene un rol asignado
        return redirect('modulo_educadores:default_home')

@login_required
def home_educador(request):
    """
    Home page para los educadores.
    """
    user = request.user
    return render(request, 'modulo_educadores/home_educador.html', {'usuario': user})

@login_required
def calendario_educador(request):
    """
    Muestra los pagos asignados al educador actual.
    """
    pagos = PaymentSchedule.objects.filter(assigned_to=request.user).order_by('payment_date')
    return render(request, 'modulo_educadores/calendario_educador.html', {'pagos': pagos})
