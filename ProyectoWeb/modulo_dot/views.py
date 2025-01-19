from django.contrib.auth.decorators import login_required
from django.shortcuts import render, redirect, get_object_or_404
from django.contrib import messages
from django.contrib.auth.hashers import make_password
from modulo_apec.models import ServicioEducativo
from form_app.models import Aspirante
from login_app.models import UsuarioRol  # Este modelo es para crear usuarios con roles
from .forms import UsuarioForm, DatosPersonalesForm, DocumentosPersonalesForm, StatusesForm, FirmaDigitalForm
from login_app.decorators import role_required
from .models import Usuario, UsuarioRol
from modulo_dot.models import DatosPersonales
from login_app.models import Statuses
from django.http import JsonResponse
import json
from django.views.decorators.csrf import csrf_exempt
from django.conf import settings
import os
from django.db import transaction
from modulo_coordinador.models import ConveniosFiguras
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
                nuevo_usuario = usuario_form.cleaned_data.get('usuario')
                nueva_contrasenia = usuario_form.cleaned_data.get('contrasenia')
                nuevo_rol = usuario_form.cleaned_data.get('rol')

                if nueva_contrasenia:
                    # Encriptar la nueva contraseña y actualizarla en el modelo UsuarioRol
                    usuario.usuario_rol.username = nuevo_usuario  # Actualizar el nombre de usuario
                    usuario.usuario_rol.password = make_password(nueva_contrasenia)  # Encriptada en UsuarioRol
                    usuario.contrasenia = nueva_contrasenia  # Guardar la contraseña en texto plano en Empleado
                    usuario.usuario_rol.role = nuevo_rol  # Actualizar el rol en UsuarioRol
                    
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


@login_required
@role_required("DOT")
def dashboard_eleminar(request):
    empleados = DatosPersonales.objects.select_related('usuario')  # Trae relación con Usuario
    return render(
        request, "home_dot/dasboard_eleminar.html", {"empleados": empleados}
    )


@login_required
@role_required("DOT")
def eliminar_empleado(request, empleado_id):
    empleado = get_object_or_404(DatosPersonales, id=empleado_id)
    usuario = empleado.usuario

    try:
        with transaction.atomic():
            # Operaciones de eliminación
            Statuses.objects.filter(usuario=usuario).delete()
            if usuario.usuario_rol:
                usuario.usuario_rol.delete()
            Aspirante.objects.filter(usuario=usuario).delete()
            if hasattr(empleado, 'documentos'):
                empleado.documentos.delete()
            usuario.delete()
            empleado.delete()

        messages.success(request, f"El empleado {empleado.nombre} ha sido eliminado junto con todas sus relaciones.")
    except Exception as e:
        messages.error(request, f"Hubo un error al eliminar el empleado: {e}")
    
    return redirect('dot_home:dashboard_eleminar')


@login_required
@role_required("DOT")
def visualizar_docs(request):
    # Ruta absoluta de la carpeta donde se almacenan los documentos
    carpeta_documentos = os.path.join(settings.MEDIA_ROOT, 'documentos')
    
    # Obtener una lista de los archivos en esa carpeta
    documentos = []
    if os.path.exists(carpeta_documentos):
        documentos = os.listdir(carpeta_documentos)  # Lista los archivos en la carpeta
    
    # Pasar la lista de documentos y MEDIA_URL a la plantilla
    return render(request, "home_dot/visualizacion_docs.html", {
        'documentos': documentos,
        'MEDIA_URL': settings.MEDIA_URL,  # Pasa MEDIA_URL a la plantilla
    })

@login_required
@role_required("DOT","CT", "APEC")
def dashboard_vacantes(request):
    servicios = ServicioEducativo.objects.all()
    return render(request, 'home_dot/dashboard_vacantes.html', {'servicios': servicios})


@login_required
@role_required("DOT")
def dashboard_convenios(request):
    # Filtrar convenios con usuario asignado y que no tengan el rol 'ASPIRANTE'
    convenios = ConveniosFiguras.objects.filter(usuario__isnull=False).exclude(usuario__rol='ASPIRANTE')

    if request.method == 'POST' and 'agregar_firma' in request.POST:
        convenio_id = request.POST.get('convenio_id')
        convenio = ConveniosFiguras.objects.get(id=convenio_id)

        # Procesamos la firma digital
        if request.FILES.get('firma_digital'):
            convenio.firma_digital = request.FILES['firma_digital']
            convenio.save()
            return redirect('dot_home:dashboard_convenios')

    return render(request, 'home_dot/dashboard_convenios.html', {
        'convenios': convenios,
    })


from PyPDF2 import PdfReader, PdfWriter
from reportlab.pdfgen import canvas
from reportlab.lib.pagesizes import letter
from io import BytesIO
from PIL import Image, ImageEnhance
import base64
import os  
from django.core.files.base import ContentFile
@csrf_exempt  # Solo si no estás usando protección CSRF en la solicitud
def save_signature(request):
    if request.method == 'POST':
        try:
            data = json.loads(request.body)
            signature_data = data.get('signature')
            convenio_id = data.get('convenio_id')

            if not convenio_id:
                return JsonResponse({'status': 'error', 'message': 'ID del convenio no proporcionado'}, status=400)

            convenio = ConveniosFiguras.objects.get(id=convenio_id)

            # Obtener el usuario autenticado (UsuarioRol)
            usuario_rol = request.user  # Este es el objeto UsuarioRol
            if not usuario_rol:  # Si no hay un usuario autenticado
                return JsonResponse({'status': 'error', 'message': 'Usuario no autenticado'}, status=400)
            
            usuario_autenticado = usuario_rol.usuario
             # Asignar al firmante
            if not convenio.firmado_por:
                convenio.firmado_por = usuario_autenticado
                
            # Convertir base64 a imagen
            img_data = base64.b64decode(signature_data.split(',')[1])
            image = Image.open(BytesIO(img_data))
            
            # Convertir a RGBA si no lo está ya
            if image.mode != 'RGBA':
                image = image.convert('RGBA')
            
            # Mejorar el contraste
            enhancer = ImageEnhance.Contrast(image)
            image = enhancer.enhance(2.0)  # Aumentar contraste (ajusta el valor según necesites)
            
            # Mejorar la nitidez
            enhancer = ImageEnhance.Sharpness(image)
            image = enhancer.enhance(1.5)  # Aumentar nitidez
            
            # Ajustar el brillo si es necesario
            enhancer = ImageEnhance.Brightness(image)
            image = enhancer.enhance(0.9)  # Reducir un poco el brillo para hacer la firma más oscura
            
            # Crear máscara de transparencia mejorada
            r, g, b, a = image.split()
            # Hacer los trazos más oscuros
            a = ImageEnhance.Contrast(a).enhance(1.5)
            
            # Recombinar los canales
            image = Image.merge('RGBA', (r, g, b, a))
            
            firma_temp_path = f"media/firmas/temp_firma_{convenio.usuario.usuario}.png"
            # Guardar con mejor calidad
            image.save(firma_temp_path, 'PNG', quality=95)

            # Procesar PDF con la firma mejorada
            pdf_path = convenio.convenio_pdf.path
            output_pdf_path = f"media/firmas/convenio_firmado_{convenio.usuario.usuario}.pdf"
            
            # Ahora pasamos el convenio_id a agregar_firma
            agregar_firma(pdf_path, firma_temp_path, output_pdf_path, convenio_id=convenio.id)

            with open(output_pdf_path, 'rb') as pdf_file:
                convenio.firma_digital.save(
                    f"convenio_firmado_{convenio.usuario.usuario}.pdf",
                    ContentFile(pdf_file.read()),
                    save=True
                )

            os.remove(firma_temp_path)
            
            return JsonResponse({'status': 'success', 'firma_pdf_path': convenio.firma_digital.url})
            
        except Exception as e:
            return JsonResponse({'status': 'error', 'message': str(e)}, status=500)
        

from reportlab.lib.pagesizes import letter
from reportlab.lib import colors

def agregar_firma(pdf_path, firma_path, output_path, convenio_id):
    # Obtener el convenio usando el convenio_id
    convenio = ConveniosFiguras.objects.get(id=convenio_id)  # Filtrar por ID del convenio
    control_numero = convenio.control_numero  # Número de control
    
    # Obtener el usuario relacionado con el convenio y sus datos personales
    usuario = convenio.usuario
    datos_personales = DatosPersonales.objects.get(usuario=usuario)
    nombre = datos_personales.nombre
    apellidopa = datos_personales.apellidopa
    apellidoma = datos_personales.apellidoma

    reader = PdfReader(pdf_path)
    writer = PdfWriter()

    # Crear un PDF temporal para el número de control y las firmas
    packet = BytesIO()
    c = canvas.Canvas(packet, pagesize=letter)
    
    # Dibujar el número de control en todas las páginas
    c.setFont("Helvetica", 10)  # Establecer la fuente y tamaño
    c.setFillColor(colors.black)  # Establecer el color del texto
     # Dibujar el nombre completo en la primera página en las coordenadas especificadas
    c.setFont("Helvetica-Bold", 10)
    c.setFillColor(colors.black)
    c.drawString(225.04, 608.7, f"{nombre} {apellidopa} {apellidoma}")

    # Dibujar el número de control en todas las páginas
    c.setFont("Helvetica-Bold", 10)  # Restablecer la fuente y tamaño

    # Recorrer todas las páginas para añadir el número de control
    for i in range(len(reader.pages)):  
        # Dibujar el número de control en todas las páginas
        c.drawString(450.63, 758.64, f"{control_numero}")  # Ajustar la posición en la esquina superior derecha

        # Si es la página 4 (índice 4 es la quinta página, ajusta según sea necesario)
        if i == 4:
            
            # Dibujar la firma digital
            img = Image.open(firma_path)
            width = 150.43504 - 54.0
            aspect = img.height / img.width
            height = width * aspect

            # Dibujar las firmas con mayor opacidad
            c.drawImage(firma_path, x=54.0, y=350.59, width=width, height=height, mask='auto', preserveAspectRatio=True)
            c.drawImage(firma_path, x=54.0, y=250.17, width=width, height=height, mask='auto', preserveAspectRatio=True)
            c.drawImage(firma_path, x=54.0, y=150.37, width=width, height=height, mask='auto', preserveAspectRatio=True)
        
        c.showPage()  # Añadir una nueva página al canvas para seguir con la siguiente página

    c.save()

    packet.seek(0)
    control_y_firma_pdf = PdfReader(packet)

    # Añadir las páginas del archivo de control y firmas al PDF de salida
    for i, page in enumerate(reader.pages):
        # Combinamos el contenido de la página original con el control y las firmas (si es la página correspondiente)
        page.merge_page(control_y_firma_pdf.pages[i])  # Añadir el texto (número de control) y las firmas al PDF

        # Añadir la página modificada al PDF de salida
        writer.add_page(page)

    with open(output_path, "wb") as output_file:
        writer.write(output_file)