from django import forms
from modulo_dot.models import DatosPersonales
from .models import Aspirante, validate_phone_number, Gestion, Residencia, Banco, Participacion
from django.core.validators import RegexValidator, FileExtensionValidator
from django.core.exceptions import ValidationError
from django.core.validators import MinValueValidator
from web_conafe.const import ESTADOS_MEXICO, BANCO_CHOICES, LINGUA_CHOICES, formacion_academica_CHOICES


class RegistroAspiranteForm(forms.ModelForm):
    class Meta:
        model = Aspirante
        fields = ['datos_personales', 'fotografia']

    # Campos de datos personales
    nombre = forms.CharField(max_length=100, label="Nombre")
    apellidopa = forms.CharField(max_length=100, label="Apellido Paterno")
    apellidoma = forms.CharField(max_length=100, label="Apellido Materno")
    correo = forms.EmailField(label="Correo Electrónico")
    telefono = forms.CharField(
        max_length=15,
        label="Número de Teléfono",
        required=True,
        validators=[validate_phone_number]
    )
    sexo = forms.ChoiceField(
        choices=[("Masculino", "Masculino"), ("Femenino", "Femenino"), ("Otro", "Otro")],
        label="Sexo"
    )
    edad = forms.IntegerField(label="Edad")
    formacion_academica = forms.ChoiceField(
        choices=formacion_academica_CHOICES,
        label="Nivel Académico"
    )
    curp = forms.CharField(max_length=18, label="CURP", validators=[RegexValidator(r'^[A-Z0-9]{18}$', 'CURP no válido')])

    # Pregunta sobre lengua indígena
    habla_lengua_indigena = forms.ChoiceField(
        choices=[('si', 'Si'), ('no', 'No')],
        label="¿Hablas alguna lengua indígena?",
        widget=forms.RadioSelect()
    )
    lengua_indigena = forms.ChoiceField(
        choices=LINGUA_CHOICES,
        label="¿Qué lengua indígena hablas?",
        required=False
    )

    # Campos de gestión
    talla_playera = forms.ChoiceField(
        choices=[('S', 'S'), ('M', 'M'), ('L', 'L'), ('XL', 'XL')],
        label="Talla de Playera"
    )
    talla_pantalon = forms.ChoiceField(
        choices=[(str(i), str(i)) for i in range(28, 43)],
        label="Talla de Pantalón"
    )
    talla_calzado = forms.ChoiceField(
        choices=[(str(i / 2), str(i / 2)) for i in range(49, 59)],
        label="Talla de Calzado (MX)"
    )
    peso = forms.FloatField(
        label="Peso (kg)",
        validators=[MinValueValidator(1, message="El peso debe ser un valor positivo")]
    )
    estatura = forms.FloatField(
        label="Estatura (m)",
        validators=[MinValueValidator(0.5, message="La estatura debe ser un valor positivo")]
    )
    medio_publicitario = forms.ChoiceField(
        choices=[('Redes Sociales', 'Red Social'), ('Radio', 'Radio'),
                 ('Recomendacion', 'Recomendacion'), ('Television', 'Television')],
        label="¿Cómo te enteraste de la convocatoria?"
    )

    # Información bancaria
    banco = forms.ChoiceField(choices=BANCO_CHOICES, label="Banco")
    cuenta_bancaria = forms.CharField(
        max_length=50,
        label="Cuenta Bancaria",
        validators=[RegexValidator(r'^[0-9]+$', 'Solo se permiten números en la cuenta bancaria')]
    )

    # Información de residencia
    codigo_postal = forms.CharField(
        max_length=5,
        label="Código Postal",
        validators=[RegexValidator(r'^[0-9]+$', 'Solo se permiten números')]
    )
    estado = forms.ChoiceField(choices=ESTADOS_MEXICO, label="Estado")
    municipio = forms.CharField(max_length=100, label="Municipio o Alcaldía")
    localidad = forms.CharField(max_length=100, label="Localidad")
    colonia = forms.CharField(max_length=100, label="Colonia")
    calle = forms.CharField(max_length=100, label="Calle")

    estado_participacion = forms.ChoiceField(choices=ESTADOS_MEXICO, label="Estado en el que deseas participar")
    ciclo_escolar = forms.ChoiceField(
        choices=[('2025-2026', '2025-2026'), ('2026-2027', '2026-2027')],
        label="Ciclo Escolar"
    )

    # Documentos
    identificacion_oficial = forms.FileField(
        label="Identificación oficial",
        validators=[FileExtensionValidator(allowed_extensions=['pdf', 'jpg', 'png'])]
    )
    fotografia = forms.FileField(
        label="Fotografía reciente",
        validators=[FileExtensionValidator(allowed_extensions=['jpg', 'png'])]
    )
    comprobante_domicilio = forms.FileField(
        label="Comprobante de domicilio",
        validators=[FileExtensionValidator(allowed_extensions=['pdf', 'jpg', 'png'])]
    )
    certificado_estudio = forms.FileField(
        label="Certificado de estudio",
        validators=[FileExtensionValidator(allowed_extensions=['pdf', 'jpg', 'png'])]
    )

    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        for field in self.fields.values():
            if isinstance(field.widget, forms.widgets.FileInput):
                field.widget.attrs.update({'class': 'form-control-file'})
            elif isinstance(field.widget, forms.widgets.RadioSelect):
                field.widget.attrs.update({'class': 'form-check-input'})
            else:
                field.widget.attrs.update({'class': 'form-control'})

    def clean(self):
        cleaned_data = super().clean()
        habla_lengua = cleaned_data.get('habla_lengua_indigena')
        lengua = cleaned_data.get('lengua_indigena')

        if habla_lengua == 'si':
            cleaned_data['habla_lengua_indigena'] = True
        else:
            cleaned_data['habla_lengua_indigena'] = False

        if habla_lengua == 'si' and not lengua:
            self.add_error('lengua_indigena', 'Debe seleccionar una lengua indígena.')

        return cleaned_data

    def save(self, commit=True):
        aspirante = super().save(commit=False)

        # Crear o actualizar datos personales
        datos_personales, _ = DatosPersonales.objects.get_or_create(
            aspirante=aspirante,
            defaults={
                'nombre': self.cleaned_data['nombre'],
                'apellidopa': self.cleaned_data['apellidopa'],
                'apellidoma': self.cleaned_data['apellidoma'],
                'correo': self.cleaned_data['correo'],
                'telefono': self.cleaned_data['telefono'],
                'formacion_academica': self.cleaned_data['formacion_academica'],
                'curp': self.cleaned_data['curp'],
            }
        )

        # Guardar información en modelos relacionados
        gestion = Gestion.objects.create(
            aspirante=aspirante,
            talla_playera=self.cleaned_data['talla_playera'],
            talla_pantalon=self.cleaned_data['talla_pantalon'],
            talla_calzado=self.cleaned_data['talla_calzado'],
            peso=self.cleaned_data['peso'],
            estatura=self.cleaned_data['estatura'],
            medio_publicitario=self.cleaned_data['medio_publicitario'],
            habla_lengua_indigena=self.cleaned_data['habla_lengua_indigena'],
            lengua_indigena=self.cleaned_data.get('lengua_indigena')
        )

        Residencia.objects.create(
            aspirante=aspirante,
            codigo_postal=self.cleaned_data['codigo_postal'],
            estado=self.cleaned_data['estado'],
            municipio_alcaldia=self.cleaned_data['municipio'],
            localidad=self.cleaned_data['localidad'],
            colonia=self.cleaned_data['colonia'],
            calle=self.cleaned_data['calle']
        )

        Banco.objects.create(
            aspirante=aspirante,
            banco=self.cleaned_data['banco'],
            cuenta_bancaria=self.cleaned_data['cuenta_bancaria']
        )

        Participacion.objects.create(
            aspirante=aspirante,
            estado_participacion=self.cleaned_data['estado_participacion'],
            ciclo_escolar=self.cleaned_data['ciclo_escolar']
        )

        if commit:
            aspirante.save()

        return aspirante


