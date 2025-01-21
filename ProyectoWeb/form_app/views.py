from django.shortcuts import render, redirect, get_object_or_404
from .forms import RegistroAspiranteForm
from .models import Residencia, Participacion, Gestion, Banco, Aspirante, Usuario
from modulo_dot.models import DatosPersonales, DocumentosPersonales
from django.db import transaction
from login_app.models import UsuarioRol
from .models import Aspirante
def form_view(request):
    if request.method == "POST":
        form = RegistroAspiranteForm(request.POST, request.FILES)
        if form.is_valid():
            # Usamos transaction.atomic para asegurarnos de que todas las operaciones sean atómicas
            with transaction.atomic():

                # Crear el Usuario relacionado al aspirante
                usuario = Usuario.objects.create(  # O algún campo que identifique al usuario
                    rol="ASPIRANTE"
                )

                # Relacionar usuario_rol si es necesario
                if not usuario.usuario_rol:
                    usuario.usuario_rol = UsuarioRol.objects.create(
                        username=None,
                        role="ASPIRANTE",
                        password=None
                    )
                    usuario.save()
                
                # Crear el objeto DatosPersonales
                datos_personales = DatosPersonales.objects.create(
                    nombre=form.cleaned_data["nombre"],
                    apellidopa=form.cleaned_data["apellidopa"],
                    apellidoma=form.cleaned_data["apellidoma"],
                    correo=form.cleaned_data["correo"],
                    telefono=form.cleaned_data["telefono"],
                    sexo=form.cleaned_data["sexo"],
                    edad=form.cleaned_data["edad"],
                    formacion_academica=form.cleaned_data["formacion_academica"],
                    curp=form.cleaned_data["curp"],
                    fotografia=form.cleaned_data.get("fotografia"),
                    usuario=usuario  # Asociamos el usuario a los datos personales
                )
                

                # Crear el objeto Aspirante
                aspirante = Aspirante.objects.create(
                    datos_personales=datos_personales,
                    usuario=usuario  # Asociamos el usuario al aspirante
                )

                # Los objetos relacionados con la gestión, residencia, banco y participación
                gestion = Gestion.objects.create(
                    aspirante=aspirante,
                    talla_playera=form.cleaned_data['talla_playera'],
                    talla_pantalon=form.cleaned_data['talla_pantalon'],
                    talla_calzado=form.cleaned_data['talla_calzado'],
                    peso=form.cleaned_data['peso'],
                    estatura=form.cleaned_data['estatura'],
                    medio_publicitario=form.cleaned_data['medio_publicitario'],
                    habla_lengua_indigena=form.cleaned_data['habla_lengua_indigena'],
                    lengua_indigena=form.cleaned_data['lengua_indigena'] if form.cleaned_data['habla_lengua_indigena'] else None,
                )

                residencia = Residencia.objects.create(
                    aspirante=aspirante,
                    codigo_postal=form.cleaned_data['codigo_postal'],
                    estado=form.cleaned_data['estado'],
                    municipio_alcaldia=form.cleaned_data['municipio'],
                    colonia=form.cleaned_data['colonia'],
                    calle=form.cleaned_data['calle']
                )

                banco = Banco.objects.create(
                    aspirante=aspirante,
                    banco=form.cleaned_data['banco'],
                    cuenta_bancaria=form.cleaned_data['cuenta_bancaria']
                )

                participacion = Participacion.objects.create(
                    aspirante=aspirante,
                    estado_participacion=form.cleaned_data['estado_participacion'],
                    ciclo_escolar=form.cleaned_data['ciclo_escolar'],
                    tipo_servicio=form.cleaned_data['tipo_servicio'],
                    contexto=form.cleaned_data['contexto'],
                    programa_participacion=form.cleaned_data['programa_participacion']
                )

                # Guardamos la fotografía si fue subida
                if form.cleaned_data.get('fotografia'):
                    aspirante.fotografia = form.cleaned_data['fotografia']
                    aspirante.save()

                # Guardamos los documentos personales si están presentes
                if form.cleaned_data.get('identificacion_oficial'):
                    DocumentosPersonales.objects.create(
                        datos_personales=aspirante.datos_personales,
                        identificacion_oficial=form.cleaned_data['identificacion_oficial'],
                        comprobante_domicilio=form.cleaned_data.get('comprobante_domicilio'),
                        certificado_estudio=form.cleaned_data.get('certificado_estudio')
                    )

                # Redirigir a una página de éxito o confirmación
                return redirect('confirmacion', aspirante_id=aspirante.id)
    else:
        form = RegistroAspiranteForm()

    return render(request, 'app_form/template_form.html', {'form': form})

def confirmacion(request, aspirante_id):
    # Recuperar el aspirante por su ID
    aspirante = get_object_or_404(Aspirante, id=aspirante_id)
    
    return render(request, 'app_form/confirmacion.html', {'aspirante': aspirante})