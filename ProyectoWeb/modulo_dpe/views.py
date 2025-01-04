from django.shortcuts import render
from login_app.decorators import role_required
from django.contrib.auth.decorators import login_required
from modulo_apec.models import ServicioEducativo
# Create your views here.
@login_required
@role_required("DPE")
def view_home_dpe(request):
    return render(request, 'home_dpe/home_dpe.html')

@login_required
@role_required("DPE")
def dashboard_vacantes_dpe(request):
    servicios = ServicioEducativo.objects.all()
    return render(request, 'home_dpe/dashboard_vacantes_dpe.html', {'servicios': servicios})