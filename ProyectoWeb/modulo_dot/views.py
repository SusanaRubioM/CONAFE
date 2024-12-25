from django.contrib.auth.decorators import login_required
from django.shortcuts import render, redirect, get_object_or_404
from django.contrib import messages
from form_app.models import Aspirante
from login_app.models import UsuarioRol  # Este modelo es para crear usuarios con roles
from .forms import UsuarioForm, DatosPersonalesForm, DocumentosPersonalesForm
from login_app.decorators import role_required
from .models import Usuario, UsuarioRol

@login_required
@role_required("DOT")  # Solo los usuarios con rol 'DOT' pueden acceder
def home_view(request):
    """
    Vista principal del portal para el rol 'DOT'.
    """
    return render(request, "home_dot/dot_home.html")


@login_required
@role_required("DOT")
def agregar_trabajador(request):
    """
    Vista para agregar un nuevo trabajador. Solo accesible para el rol 'DOT'.
    """
    if request.method == "POST":
        # Crear instancias de los formularios con los datos POST
        usuario_form = UsuarioForm(request.POST)
        datos_personales_form = DatosPersonalesForm(request.POST, request.FILES)
        documentos_form = DocumentosPersonalesForm(request.POST, request.FILES)

        # Validar los formularios
        if (
            usuario_form.is_valid()
            and datos_personales_form.is_valid()
            and documentos_form.is_valid()
        ):
            # Crear y guardar el nuevo usuario
            usuario = usuario_form.save(commit=False)
            usuario.save()

            # Obtener el rol desde el formulario
            rol = usuario_form.cleaned_data['rol']

            # Verificar si ya existe un UsuarioRol con el rol proporcionado (usuario y rol únicos)
            usuario_rol = UsuarioRol.objects.filter(role=rol, usuario=usuario).first()
            if not usuario_rol:
                # Si no existe, creamos un nuevo UsuarioRol
                usuario_rol = UsuarioRol.objects.create(role=rol, usuario=usuario, password=usuario.contrasenia)

            # Asociamos el UsuarioRol al Usuario
            usuario.usuario_rol = usuario_rol
            usuario.save()

            # Crear y guardar los datos personales asociados al usuario
            datos_personales = datos_personales_form.save(commit=False)
            datos_personales.usuario = usuario  # Asociamos el usuario con los datos personales
            datos_personales.save()

            # Crear y guardar los documentos personales asociados a los datos personales
            documentos_personales = documentos_form.save(commit=False)
            documentos_personales.datos_personales = datos_personales  # Asociamos los documentos con DatosPersonales
            documentos_personales.save()

            # Crear el aspirante y asociar los datos personales
            aspirante = Aspirante.objects.create(
                datos_personales=datos_personales,
                usuario=usuario  # Asociamos el usuario al aspirante
            )

            # Si el rol del usuario es 'ASPIRANTE', asignamos un folio
            if usuario.rol == "ASPIRANTE":
                aspirante.asignacion_folio()  # Asigna el folio al aspirante si es necesario
                aspirante.save()

            # Mensaje de éxito
            messages.success(request, "¡Trabajador agregado exitosamente!")

            # Redirigir a la página principal
            return redirect("dot_home:home_dot")
        else:
            # Si hay errores en los formularios, imprimimos los errores para depuración
            print("Errores en UsuarioForm:", usuario_form.errors)
            print("Errores en DatosPersonalesForm:", datos_personales_form.errors)
            print("Errores en DocumentosPersonalesForm:", documentos_form.errors)

            # Mensaje de error al usuario
            messages.error(
                request,
                "Hubo errores en el formulario. Verifique los datos ingresados.",
            )
    else:
        # Si no es un POST, crear instancias vacías de los formularios
        usuario_form = UsuarioForm()
        datos_personales_form = DatosPersonalesForm()
        documentos_form = DocumentosPersonalesForm()

    return render(
        request,
        "home_dot/home_agregar.html",  # Ruta al template
        {
            "usuario_form": usuario_form,
            "datos_personales_form": datos_personales_form,
            "documentos_personales_form": documentos_form,  # Asegúrate de usar este nombre
        },
    )

@login_required
@role_required("DOT")
def dashboard_view(request):
    """
    Vista para mostrar el dashboard con todos los empleados.
    """
    # Obtener todos los empleados registrados
    empleados = UsuarioRol.objects.all()
    return render(
        request, "home_dot/dashboard_visualizar.html", {"empleados": empleados}
    )


@login_required
@role_required("DOT")
def detalles_empleado(request, empleado_id):
    """
    Vista para ver los detalles de un empleado en específico.
    """
    empleado = get_object_or_404(UsuarioRol, id=empleado_id)
    return render(request, "home_dot/detalles_empleado.html", {"empleado": empleado})


@login_required
@role_required("DOT")
def modificar_dashboard(request):
    """
    Vista para modificar la información de los empleados, mostrando el dashboard.
    """
    empleados = UsuarioRol.objects.all()  # Obtener todos los empleados
    return render(
        request, "home_dot/dashboard_modificar.html", {"empleados": empleados}
    )


@login_required
@role_required("DOT")
def modificar_empleado(request, empleado_id):
    """
    Vista para modificar la información de un empleado específico.
    """
    empleado = get_object_or_404(UsuarioRol, id=empleado_id)
    usuario = empleado.usuario  # Obtenemos el usuario relacionado con el empleado

    if request.method == "POST":
        # Instanciar los formularios con los datos de POST y las instancias correspondientes
        usuario_form = UsuarioForm(request.POST, instance=usuario)
        datos_personales_form = DatosPersonalesForm(
            request.POST, request.FILES, instance=empleado.datos_personales
        )
        documentos_form = DocumentosPersonalesForm(
            request.POST, request.FILES, instance=empleado.datos_personales.documentos.first()
        )

        if usuario_form.is_valid() and datos_personales_form.is_valid() and documentos_form.is_valid():
            # Guardar los cambios
            usuario_form.save()
            datos_personales_form.save()
            documentos_form.save()

            # Mensaje de éxito
            messages.success(
                request, "El registro del empleado ha sido modificado correctamente."
            )
            return redirect("dot_home:dashboard_modificar")

    else:
        # Crear las instancias de los formularios con los datos actuales del empleado
        usuario_form = UsuarioForm(instance=usuario)
        datos_personales_form = DatosPersonalesForm(instance=empleado.datos_personales)
        documentos_form = DocumentosPersonalesForm(
            instance=empleado.datos_personales.documentos.first() if empleado.datos_personales.documentos.exists() else None
        )

    return render(
        request,
        "home_dot/modificar_empleado.html",
        {
            "usuario_form": usuario_form,
            "datos_personales_form": datos_personales_form,
            "documentos_form": documentos_form,  # Asegúrate de mostrar este formulario también
            "empleado": empleado,
        },
    )
