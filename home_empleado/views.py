from django.shortcuts import render
from login_app.decorators import role_required # Importa desde donde esté el archivo `decorators.py`
from django.contrib.auth.decorators import login_required



@login_required
@role_required('EC')
def empleado_view(request):
    return render(request, 'home_empleado/empleado.html')
