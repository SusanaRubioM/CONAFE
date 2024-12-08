from django.shortcuts import render, redirect
from django.contrib import messages
from .forms import RegistroAspiranteForm
from .models import Aspirante , FormacionAcademica , InformacionAdicional, Residencia, Participacion, Documentos

def form_view(request):
    if request.method == 'POST':
        form = RegistroAspiranteForm(request.POST, request.FILES)
        if form.is_valid():
            
            # Imprimir datos validados
            print(form.cleaned_data)  # Esto te ayudará a ver qué datos se han procesado correctamente
            
            # Guardar la información del aspirante
            aspirante = Aspirante.objects.create(
                nombre=form.cleaned_data['nombre'],
                apellido_paterno=form.cleaned_data['apellido_paterno'],
                apellido_materno=form.cleaned_data['apellido_materno'],
                correo=form.cleaned_data['correo'],
                telefono=form.cleaned_data['telefono']  # Asegúrate de que esto sea un string
            )

            
            # Obtén directamente el valor booleano desde cleaned_data
            habla_lengua_indigena = form.cleaned_data['habla_lengua_indigena']  # Esto ya es True o False gracias al método clean_habla_lengua_indigena

            # Crear la instancia de FormacionAcademica
            FormacionAcademica.objects.create(
                aspirante=aspirante,  # Objeto aspirante ya creado anteriormente
                nivel_academico=form.cleaned_data['nivel_academico'],  # Tomamos directamente el valor del formulario
                certificado_constancia=form.cleaned_data['certificado_constancia'],
                habla_lengua_indigena=habla_lengua_indigena  # Asignamos el valor booleano
            )

                        # Crear Información Adicional
            InformacionAdicional.objects.create(
                aspirante=aspirante,
                habla_lengua_indigena=form.cleaned_data['habla_lengua_indigena'] == 'sí',
                talla_playera=form.cleaned_data['talla_playera'],
                talla_pantalon=form.cleaned_data['talla_pantalon'],
                talla_calzado=form.cleaned_data['talla_calzado'],
                banco=form.cleaned_data['banco'],
                cuenta_bancaria=form.cleaned_data['cuenta_bancaria']
            )

            # Crear Residencia
            Residencia.objects.create(
                aspirante=aspirante,
                codigo_postal=form.cleaned_data['codigo_postal'],
                estado=form.cleaned_data['estado'],
                municipio=form.cleaned_data['municipio'],
                localidad=form.cleaned_data['localidad'],
                colonia=form.cleaned_data['colonia']
            )

            # Crear Participación
            Participacion.objects.create(
                aspirante=aspirante,
                estado_participacion=form.cleaned_data['estado_participacion'],
                ciclo_escolar=form.cleaned_data['ciclo_escolar']
            )

            # Crear Documentos
            Documentos.objects.create(
                aspirante=aspirante,
                identificacion_oficial=form.cleaned_data['identificacion_oficial'],
                fotografia=form.cleaned_data['fotografia'],
                comprobante_domicilio=form.cleaned_data['comprobante_domicilio']
            )


            # Mensaje de éxito
            messages.success(request, 'Aspirante subido al sistema exitosamente.')

            # Redirigir a la página de confirmación
            return redirect('confirmacion')  # Aquí rediriges a la vista de confirmación
        else:
            print(form.errors)

    else:
        form = RegistroAspiranteForm()

    return render(request, 'app_form/template_form.html', {'form': form})


def confirmacion(request):
    # Renderiza una página de confirmación con un mensaje adecuado
    return render(request, 'app_form/confirmacion.html')
        


