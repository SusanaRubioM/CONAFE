from django.contrib.auth.decorators import login_required
from django.shortcuts import render, redirect, get_object_or_404
from django.contrib import messages
from django.contrib.auth.hashers import make_password
from form_app.models import Aspirante
from login_app.models import UsuarioRol  # Este modelo es para crear usuarios con roles
from .forms import UsuarioForm, DatosPersonalesForm, DocumentosPersonalesForm, StatusesForm
from login_app.decorators import role_required
from .models import Usuario, UsuarioRol
from modulo_dot.models import DatosPersonales
from login_app.models import Statuses
from django.http import JsonResponse
import json
from django.views.decorators.csrf import csrf_exempt

@login_required
@role_required("DOT")  # Solo los usuarios con rol 'DOT' pueden acceder
def home_view(request):
    empleados = DatosPersonales.objects.all()  # O el filtro que estés utilizando
    return render(request, 'home_dot/dot_home.html', {'empleados': empleados})



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
                usuario=usuario
            )

            # Asignar folio si el rol es 'ASPIRANTE'
            if usuario.rol == "ASPIRANTE":
                aspirante.asignacion_folio()  # Asigna el folio al aspirante si es necesario
            aspirante.save()  # Solo guardamos una vez

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
    # Obtener datos de empleados desde el modelo DatosPersonales
    empleados = DatosPersonales.objects.select_related('usuario')  # Trae relación con Usuario
    return render(
        request, "home_dot/dashboard_visualizar.html", {"empleados": empleados}
    )


@login_required
@role_required("DOT")
def detalles_empleado(request, empleado_id):
    """
    Vista para ver los detalles de un empleado en específico.
    """
    # Obtener el objeto DatosPersonales asociado al usuario con el id proporcionado
    empleado = get_object_or_404(DatosPersonales, usuario__id=empleado_id)  # Acceder a los datos de un empleado relacionado con Usuario
    
    # Pasar el objeto empleado a la plantilla
    return render(request, "home_dot/detalles_empleado.html", {"empleado": empleado})


@login_required
@role_required("DOT")
def modificar_dashboard(request):
    """
    Vista para modificar la información de los empleados, mostrando el dashboard.
    """
    empleados = DatosPersonales.objects.select_related('usuario')  # Trae relación con Usuario
    return render(
        request, "home_dot/dashboard_modificar.html", {"empleados": empleados}
    )


@login_required
@role_required("DOT")
def modificar_empleado(request, empleado_id):
    empleado = get_object_or_404(DatosPersonales, id=empleado_id)
    usuario = empleado.usuario

    if request.method == "POST":
        # Crear formularios con los datos del POST
        usuario_form = UsuarioForm(request.POST, instance=usuario)
        datos_personales_form = DatosPersonalesForm(request.POST, request.FILES, instance=empleado)
        documentos_form = DocumentosPersonalesForm(request.POST, request.FILES, instance=empleado.documentos)

        if usuario_form.is_valid() and datos_personales_form.is_valid() and documentos_form.is_valid():
            try:
                # Revisar si se cambió la contraseña
                nueva_contrasenia = usuario_form.cleaned_data.get('contrasenia')

                if nueva_contrasenia:
                    # Encriptar la nueva contraseña y actualizarla en el modelo UsuarioRol
                    usuario.usuario_rol.password = make_password(nueva_contrasenia)  # Encriptada en UsuarioRol
                    empleado.contrasenia = nueva_contrasenia  # Guardar la contraseña en texto plano en Empleado

                # Mantener valor original para 'sexo' en datos personales si no se cambia
                datos_personales_form.instance.sexo = empleado.sexo

                # Guardar los formularios
                usuario.usuario_rol.save()
                usuario_form.save()  # Guardar cambios en el usuario
                datos_personales_form.save()  # Guardar cambios en datos personales
                documentos_form.save()  # Guardar cambios en documentos personales

                messages.success(request, "El registro del empleado ha sido modificado correctamente.")
                return redirect("dot_home:home_dot")

            except Exception as e:
                messages.error(request, f"Hubo un error al guardar los cambios: {e}")
        else:
            messages.error(request, "Hubo un error en el formulario. Revisa los campos.")
            for form in [usuario_form, datos_personales_form, documentos_form]:
                for field, error_list in form.errors.items():
                    for error in error_list:
                        messages.error(request, f"{field}: {error}")
    else:
        # Si la petición es GET, mostrar los formularios con los datos actuales
        usuario_form = UsuarioForm(instance=usuario)
        datos_personales_form = DatosPersonalesForm(instance=empleado)
        documentos_form = DocumentosPersonalesForm(instance=empleado.documentos)

    return render(
        request,
        "home_dot/modificar_empleado.html",
        {
            "usuario_form": usuario_form,
            "datos_personales_form": datos_personales_form,
            "documentos_form": documentos_form,
            "empleado": empleado,
        },
    )



@login_required
@role_required("DOT")
def status_empleado(request):
    empleados = DatosPersonales.objects.all()
    empleados_forms = []

    for empleado in empleados:
        try:
            status = Statuses.objects.get(usuario=empleado.usuario)
        except Statuses.DoesNotExist:
            status = Statuses(usuario=empleado.usuario, status='')

        form = StatusesForm(instance=status)
        empleados_forms.append((empleado, form))

    return render(request, 'home_dot/dashboard_status.html', {'empleados_forms': empleados_forms})




@login_required
@role_required("DOT")
@csrf_exempt
def actualizar_status_ajax(request, empleado_id):
    if request.method == "POST":
        try:
            empleado = DatosPersonales.objects.get(id=empleado_id)
            status = Statuses.objects.get_or_create(usuario=empleado.usuario)[0]  # Crear estado si no existe
            data = json.loads(request.body)
            nuevo_status = data.get("status", "")

            # Validar si el estado es válido
            if nuevo_status in dict(Statuses._meta.get_field('status').choices).keys():
                status.status = nuevo_status
                status.save()
                return JsonResponse({"success": True, "message": "Estado actualizado correctamente."})
            else:
                return JsonResponse({"success": False, "message": "Estado no válido."})
        except DatosPersonales.DoesNotExist:
            return JsonResponse({"success": False, "message": "Empleado no encontrado."})
    return JsonResponse({"success": False, "message": "Método no permitido."})





