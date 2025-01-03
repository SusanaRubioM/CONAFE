from django.shortcuts import render
from login_app.decorators import role_required
from django.contrib.auth.decorators import login_required

@login_required
@role_required('APEC')
# Create your views here.
def home_view(request):
    return render(request, 'home_apec/home_apec.html')