from django.contrib.auth.decorators import login_required
from django.shortcuts import render
from login_app.decorators import role_required
from .forms import EmpleadoForm
from django.shortcuts import render, redirect
from django.contrib import messages
from login_app.models import UsuarioRol  
from .models import Empleado
from django.shortcuts import render, get_object_or_404

@login_required
@role_required('DOT')
def home_view(request):
    return render(request, 'home_dot/dot_home.html')


@login_required
@role_required('DOT')  # Solo usuarios con rol 'DOT' pueden acceder
def agregar_trabajador(request):
    """
    Vista para agregar un nuevo trabajador, solo accesible por el rol 'DOT'.
    """
    edades = range(18, 66)  # Rango de edades entre 18 y 65

    if request.method == 'POST':
        form = EmpleadoForm(request.POST, request.FILES)  # Formulario con datos del trabajador
        if form.is_valid():
            # Procesar los datos del formulario para guardar el usuario y el empleado
            # Obtener los datos del formulario
            nombre = form.cleaned_data['nombre']
            apellidopa = form.cleaned_data['apellidopa']
            apellidoma = form.cleaned_data['apellidoma']
            email = form.cleaned_data['email']
            edad = form.cleaned_data['edad']
            genero = form.cleaned_data['genero']
            salario = form.cleaned_data['salario']
            foto = form.cleaned_data['foto']
            rol = form.cleaned_data['rol']
            username = form.cleaned_data['username']
            password = form.cleaned_data['password']

            # Crear el usuario en el modelo 'UsuarioRol' con la contraseña encriptada
            usuario = UsuarioRol.objects.create_user(
                username=username,
                password=password,  # Esto encripta la contraseña automáticamente
                email=email,
                first_name=nombre,
                last_name=apellidopa,
                role=rol
            )

            # Crear el empleado en el modelo 'Empleado' (aquí guardamos la contraseña en texto claro)
            empleado = Empleado.objects.create(
                nombre=nombre,
                apellidopa=apellidopa,
                apellidoma=apellidoma,
                email=email,
                edad=edad,
                genero=genero,
                salario=salario,
                foto=foto,
                rol=rol,
                usuario=usuario,
                contrasenia=password  # Guardamos la contraseña en texto claro en el modelo 'Empleado'
            )

            # Agregar un mensaje de éxito
            messages.success(request, '¡Trabajador agregado exitosamente!')
            return redirect('dot_home:home_dot')  # Redirige a la vista 'home_dot' (dashboard principal)
    
    else:
        form = EmpleadoForm()  # Si es GET, solo se muestra el formulario vacío
    
    return render(request, 'home_dot/home_agregar.html', {'edades': edades, 'form': form})


@login_required
@role_required('DOT')  # Verifica el rol del usuario
def dashboard_view(request):
    empleados = Empleado.objects.all()  # Obtiene todos los empleados
    return render(request, 'home_dot/dashboard_visualizar.html', {'empleados': empleados})

@login_required
@role_required('DOT')
def detalles_empleado(request, empleado_id):
    empleado = get_object_or_404(Empleado, id=empleado_id)
    return render(request, 'home_dot/detalles_empleado.html', {'empleado': empleado})


@login_required
@role_required('DOT')  # Asegúrate de que solo los usuarios con este rol puedan acceder
def modificar_dashboard(request):
    empleados = Empleado.objects.all()  # Obtener todos los empleados desde la base de datos
    return render(request, 'home_dot/dashboard_modificar.html', {'empleados': empleados})  # Pasa los empleados al contexto


@login_required
@role_required('DOT')
def modificar_empleado(request, empleado_id):
    empleado = get_object_or_404(Empleado, id=empleado_id)
    usuario = empleado.usuario

    if request.method == 'POST':
        empleado.nombre = request.POST.get('nombre')
        empleado.apellidopa = request.POST.get('apellidopa')
        empleado.apellidoma = request.POST.get('apellidoma')
        empleado.email = request.POST.get('email')
        empleado.rol = request.POST.get('rol')
        usuario.username = request.POST.get('username')

        usuario.first_name = empleado.nombre
        usuario.last_name = empleado.apellidopa
        usuario.email = empleado.email
        usuario.role = empleado.rol
        usuario.username = request.POST.get('username')

        password = request.POST.get('password')
        if password:
            usuario.set_password(password)
            empleado.contrasenia = password

        usuario.save()
        empleado.save()

        messages.success(request, 'El registro del empleado ha sido modificado correctamente.')
        return redirect('dot_home:dashboard_modificar')

    # Agregamos 'username' al contexto
    context = {
        'empleado': empleado,
        'username': usuario.username,  # Incluimos el nombre de usuario actual
    }
    return render(request, 'home_dot/modificar_empleado.html', context)




