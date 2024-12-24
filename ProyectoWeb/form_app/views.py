from django.shortcuts import render, redirect
from .forms import RegistroAspiranteForm
from .models import Residencia, Participacion, Gestion, Banco, Aspirante
from modulo_dot.models import DatosPersonales, DocumentosPersonales, Usuario
from django.db import transaction

def form_view(request):
    if request.method == "POST":
        form = RegistroAspiranteForm(request.POST, request.FILES)
        if form.is_valid():
            print(form.cleaned_data['habla_lengua_indigena']) 
            # Usamos transaction.atomic para asegurarnos de que todas las operaciones sean atómicas
            with transaction.atomic():
                # Crear y guardar el objeto Usuario sin asignar los campos 'usuario' y 'contrasenia'
                usuario = Usuario.objects.create(
                    usuario=None,  # Deja el valor como None o vacío
                    contrasenia=None,  # Deja el valor como None o vacío
                    rol="ASPIRANTE",  # Asignamos el rol "ASPIRANTE"
                )
                
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
                    fotografia=form.cleaned_data.get("fotografia"),  # Asignamos la fotografía si fue subida
                    usuario=usuario,  # Asignamos el Usuario creado
                )

                # Crear el objeto Aspirante
                aspirante = Aspirante.objects.create(
                    datos_personales=datos_personales,  # Asignamos los DatosPersonales
                    usuario=usuario,  # Asignamos el Usuario
                )

                # Comprobar si 'habla_lengua_indigena' es verdadero (booleano)
                habla_lengua_indigena = form.cleaned_data['habla_lengua_indigena']

                # Crear el objeto Gestion
                gestion = Gestion.objects.create(
                    aspirante=aspirante,
                    talla_playera=form.cleaned_data['talla_playera'],
                    talla_pantalon=form.cleaned_data['talla_pantalon'],
                    talla_calzado=form.cleaned_data['talla_calzado'],
                    peso=form.cleaned_data['peso'],
                    estatura=form.cleaned_data['estatura'],
                    medio_publicitario=form.cleaned_data['medio_publicitario'],
                    habla_lengua_indigena=habla_lengua_indigena,
                    # Solo guardamos 'lengua_indigena' si 'habla_lengua_indigena' es verdadero
                    lengua_indigena=form.cleaned_data['lengua_indigena'] if habla_lengua_indigena else None,
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
                    ciclo_escolar=form.cleaned_data['ciclo_escolar']
                )

                # Aquí manejas los archivos subidos y los asignas al aspirante
                if form.cleaned_data.get('fotografia'):
                    aspirante.fotografia = form.cleaned_data['fotografia']
                    aspirante.save()  # Guarda la fotografía si fue subida

                # Guardamos los documentos personales si están presentes
                if form.cleaned_data.get('identificacion_oficial'):
                    DocumentosPersonales.objects.create(
                        datos_personales=aspirante.datos_personales,
                        identificacion_oficial=form.cleaned_data['identificacion_oficial'],
                        comprobante_domicilio=form.cleaned_data.get('comprobante_domicilio'),
                        certificado_estudio=form.cleaned_data.get('certificado_estudio')
                    )

                # Redirigir a una página de éxito o confirmación
                return render(request, "app_form/confirmacion.html")

    else:
        form = RegistroAspiranteForm()

    return render(request, 'app_form/template_form.html', {'form': form})

def confirmacion(request):
    return render(request, "app_form/confirmacion.html")
