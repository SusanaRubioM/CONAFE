from django.contrib.auth import authenticate, login
from django.shortcuts import render, redirect
from django.http import HttpResponse

def login_view(request):
    if request.method == 'POST':
        # Recibe los datos de login
        username = request.POST['username']
        password = request.POST['password']
        
        # Intenta autenticar al usuario
        user = authenticate(request, username=username, password=password)
        
        if user is not None:
            login(request, user)  # Inicia sesión con el usuario autenticado
            
            # Verificar el rol del usuario
            if user.role == 'DOT':
                # Redirige al Admin
                return redirect('dot_home:home_dot')  # Asegúrate de tener la URL correcta de admin
            elif user.role == 'EC':
                # Redirige al Empleado
                return redirect('dashboard_empleado:home_empleado')  # Asegúrate de tener la URL correcta de empleado
            elif user.role == 'CT':
                # Redirige al Empleado
                return redirect('coordinador_home:home_coordinador')  # Asegúrate de tener la URL correcta de empleado
            else:
                return HttpResponse("Access Denied: User has no role.")
        else:
            return HttpResponse("Invalid credentials")  # Si no se autenticó, muestra un error
    
    # Si el método no es POST (por ejemplo, GET), renderiza el formulario de login
    return render(request, 'login_app/login.html')



