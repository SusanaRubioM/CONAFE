from django.contrib.auth.decorators import login_required
from django.shortcuts import render, redirect, get_object_or_404
from django.contrib import messages
from login_app.models import UsuarioRol  # Este modelo es para crear usuarios con roles
from .forms import UsuarioForm, DatosPersonalesForm
from login_app.decorators import role_required

@login_required
@role_required('DOT')  # Solo los usuarios con rol 'DOT' pueden acceder
def home_view(request):
    """
    Vista principal del portal para el rol 'DOT'.
    """
    return render(request, 'home_dot/dot_home.html')


@login_required
@role_required('DOT')
def agregar_trabajador(request):
    """
    Vista para agregar un nuevo trabajador, solo accesible por el rol 'DOT'.
    """
    if request.method == 'POST':
        # Creamos las instancias de los formularios con los datos POST
        usuario_form = UsuarioForm(request.POST)
        datos_personales_form = DatosPersonalesForm(request.POST, request.FILES)

        if usuario_form.is_valid() and datos_personales_form.is_valid():
            # Crear el usuario con la contraseña encriptada
            usuario = usuario_form.save(commit=False)
            usuario.set_password(usuario_form.cleaned_data['contrasenia'])
            usuario.save()

            # Crear los datos personales del empleado y asociarlos al usuario
            datos_personales = datos_personales_form.save(commit=False)
            datos_personales.usuario = usuario
            datos_personales.save()


            # Mensaje de éxito
            messages.success(request, '¡Trabajador agregado exitosamente!')
            return redirect('dot_home:home_dot')

    else:
        # Crear instancias vacías de los formularios
        usuario_form = UsuarioForm()
        datos_personales_form = DatosPersonalesForm()

    return render(request, 'home_dot/home_agregar.html', {
        'usuario_form': usuario_form,
        'datos_personales_form': datos_personales_form,
    })

@login_required
@role_required('DOT')
def dashboard_view(request):
    """
    Vista para mostrar el dashboard con todos los empleados.
    """
    # Obtener todos los empleados registrados
    empleados = UsuarioRol.objects.all()
    return render(request, 'home_dot/dashboard_visualizar.html', {'empleados': empleados})


@login_required
@role_required('DOT')
def detalles_empleado(request, empleado_id):
    """
    Vista para ver los detalles de un empleado en específico.
    """
    empleado = get_object_or_404(UsuarioRol, id=empleado_id)
    return render(request, 'home_dot/detalles_empleado.html', {'empleado': empleado})


@login_required
@role_required('DOT')
def modificar_dashboard(request):
    """
    Vista para modificar la información de los empleados, mostrando el dashboard.
    """
    empleados = UsuarioRol.objects.all()  # Obtener todos los empleados
    return render(request, 'home_dot/dashboard_modificar.html', {'empleados': empleados})


@login_required
@role_required('DOT')
def modificar_empleado(request, empleado_id):
    """
    Vista para modificar la información de un empleado específico.
    """
    empleado = get_object_or_404(UsuarioRol, id=empleado_id)
    usuario = empleado.usuario  # Obtenemos el usuario relacionado con el empleado

    if request.method == 'POST':
        # Instanciar los formularios con los datos de POST y las instancias correspondientes
        usuario_form = UsuarioForm(request.POST, instance=usuario)
        datos_personales_form = DatosPersonalesForm(request.POST, request.FILES, instance=empleado.datos_personales)

        if usuario_form.is_valid() and datos_personales_form.is_valid():
            # Guardar los cambios
            usuario_form.save()
            datos_personales_form.save()

            # Mensaje de éxito
            messages.success(request, 'El registro del empleado ha sido modificado correctamente.')
            return redirect('dot_home:dashboard_modificar')

    else:
        # Crear las instancias de los formularios con los datos actuales del empleado
        usuario_form = UsuarioForm(instance=usuario)
        datos_personales_form = DatosPersonalesForm(instance=empleado.datos_personales)

    return render(request, 'home_dot/modificar_empleado.html', {
        'usuario_form': usuario_form,
        'datos_personales_form': datos_personales_form,
        'empleado': empleado,
    })





