from django.shortcuts import render, redirect
from django.contrib import messages
from .forms import RegistroAspiranteForm
from .models import Residencia, Participacion, Gestion
from modulo_dot.models import DatosPersonales, DocumentosPersonales


def form_view(request):
    if request.method == "POST":
        form = RegistroAspiranteForm(request.POST, request.FILES)
        if form.is_valid():
            
                # Guardar el objeto aspirante sin hacer commit inmediatamente
                aspirante = form.save(commit=False)

                # Crear datos personales
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
                    fotografia=form.cleaned_data["fotografia"],
                )

                

                # Asociar datos personales con el aspirante
                aspirante.datos_personales = datos_personales

                # Guardar el aspirante y asegurar que las relaciones se persistan
                aspirante.save()

                # Crear residencia, participación, gestión y documentos personales
                Residencia.objects.create(
                    aspirante=aspirante,
                    codigo_postal=form.cleaned_data["codigo_postal"],
                    estado=form.cleaned_data["estado"],
                    municipio_alcaldia=form.cleaned_data["municipio"],
                    localidad=form.cleaned_data["localidad"],
                    colonia=form.cleaned_data["colonia"],
                    calle=form.cleaned_data["calle"],
                )

                Participacion.objects.create(
                    aspirante=aspirante,
                    estado_participacion=form.cleaned_data["estado_participacion"],
                    ciclo_escolar=form.cleaned_data["ciclo_escolar"],
                )

                Gestion.objects.create(
                    aspirante=aspirante,
                    habla_lengua_indigena=form.cleaned_data["habla_lengua_indigena"],
                    lengua_indigena=form.cleaned_data["lengua_indigena"],
                    talla_playera=form.cleaned_data["talla_playera"],
                    talla_pantalon=form.cleaned_data["talla_pantalon"],
                    talla_calzado=form.cleaned_data["talla_calzado"],
                    peso=form.cleaned_data["peso"],
                    estatura=form.cleaned_data["estatura"],
                    medio_publicitario=form.cleaned_data["medio_publicitario"],
                )

                DocumentosPersonales.objects.create(
                    datos_personales=datos_personales,
                    identificacion_oficial=form.cleaned_data["identificacion_oficial"],
                    comprobante_domicilio=form.cleaned_data["comprobante_domicilio"],
                )

                # Confirmación de registro exitoso
                messages.success(request, "Aspirante registrado exitosamente.")
                return redirect("confirmacion")


        else:
            # Mensaje de error si el formulario no es válido
            messages.error(request, "Por favor corrige los errores del formulario.")
    else:
        # Renderizar un formulario vacío si el método es GET
        form = RegistroAspiranteForm()

    return render(request, "app_form/template_form.html", {"form": form})

# Vista de confirmación
def confirmacion(request):
    return render(request, "app_form/confirmacion.html")


