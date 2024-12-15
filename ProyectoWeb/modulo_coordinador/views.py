from django.shortcuts import render
from login_app.decorators import role_required # Importa desde donde esté el archivo `decorators.py`
from django.contrib.auth.decorators import login_required
#from form_app.models import Aspirante
from django.shortcuts import render, get_object_or_404


@login_required
@role_required('CT')
def empleado_view(request):
    return render(request, 'home_coordinador/home_coordinador.html')


"""
@role_required('CT')
def aspirante_view(request):
    aspirantes = Aspirante.objects.prefetch_related('residencias').all()
    return render(request, 'home_coordinador/dashboard_aspirante.html', {'aspirantes': aspirantes})
"""
"""
@role_required('CT')
def detalles_aspirante(request, aspirante_id):
    aspirante = get_object_or_404(Aspirante, id=aspirante_id)
    return render(request, 'home_coordinador/detalles_aspirante.html', {'aspirante': aspirante})
"""