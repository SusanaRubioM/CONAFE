from django import forms
from django.db import transaction
from .models import Aspirante, validate_phone_number, Gestion, Residencia, Banco, Participacion
from django.core.validators import RegexValidator, FileExtensionValidator
from django.core.exceptions import ValidationError
from django.core.validators import MinValueValidator
from web_conafe.const import ESTADOS_MEXICO, BANCO_CHOICES, LINGUA_CHOICES, formacion_academica_CHOICES
from modulo_dot.models import DocumentosPersonales
from modulo_coordinador.models import ConveniosFiguras
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
    edad = forms.TypedChoiceField(
        choices=[(i, str(i)) for i in range(18, 45)],  # Convertir a enteros
        label="Edad",
        coerce=int
    )

    formacion_academica = forms.ChoiceField(
        choices=formacion_academica_CHOICES,
        label="Nivel Académico"
    )
    curp = forms.CharField(max_length=18, label="CURP", validators=[RegexValidator(r'^[A-Z0-9]{18}$', 'CURP no válido')])

    # Pregunta sobre lengua indígena
    habla_lengua_indigena = forms.BooleanField(
        required=False,  # El campo no es obligatorio para que se pueda desmarcar
        widget=forms.RadioSelect(choices=[(True, 'Sí'), (False, 'No')]),  # Se usa True/False para los valores booleanos
        label="¿Hablas alguna lengua indígena?"
    )

    lengua_indigena = forms.ChoiceField(
        choices=LINGUA_CHOICES,  # Asegúrate de tener la lista de opciones de lenguas indígenas
        required=False,  # Este campo solo será obligatorio si 'habla_lengua_indigena' es verdadero
        label='¿Qué lengua indígena hablas?'
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

    estatura = forms.TypedChoiceField(
        choices=[(i / 100, f"{i / 100:.2f}") for i in range(150, 201)],  # Opciones en metros
        label="Estatura (m)",
        coerce=float,  # Convertir el valor ingresado a float
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
    colonia = forms.CharField(max_length=100, label="Colonia")
    calle = forms.CharField(max_length=100, label="Calle")

    estado_participacion = forms.ChoiceField(choices=ESTADOS_MEXICO, label="Estado en el que deseas participar")
    ciclo_escolar = forms.ChoiceField(
        choices=[('2025-2026', '2025-2026'), ('2026-2027', '2026-2027')],
        label="Ciclo Escolar"
    )
    tipo_servicio = forms.ChoiceField(choices=[('Inicial', 'Inicial'), ('Preescolar', 'Preescolar')
                                              ,('Primaria', 'Primaria'), ('Secundaria', 'Secundaria'),
                                               ('postsecundaria', 'postsecundaria') ], label="Tipo de Servicio")
    
    programa_participacion = forms.ChoiceField(
    choices=[("EC", "Educador Comunitario"),
             ("ECA", "Educador Comunitario de Acompañamiento Microrregional"),
             ("ECAR", "Educador Comunitario de Acompañamiento Regional")]
)
                                                    
    
    contexto = forms.ChoiceField(
        choices=[
            ('Rural', 'Rural'),
            ('Urbano', 'Urbano'),
            ('Indígena', 'Indígena'),
            ('Mestizo', 'Mestizo'),
            ('Migrante', 'Migrante'),
            ('Circense', 'Circense'),
            ('Grupos Vulnerables', 'Grupos Vulnerables'),
            ('Excluidos del Sistema Regular', 'Excluidos del Sistema Regular'),
        ],
        label="Contexto"
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
        habla_lengua_indigena = cleaned_data.get('habla_lengua_indigena')
        lengua_indigena = cleaned_data.get('lengua_indigena')

        # Si 'habla_lengua_indigena' es True, entonces 'lengua_indigena' debe ser obligatorio
        if habla_lengua_indigena and not lengua_indigena:
            self.add_error('lengua_indigena', 'Este campo es obligatorio si seleccionas que hablas una lengua indígena.')

        return cleaned_data
    
    def clean_estatura(self):
        # Convertir metros a centímetros antes de guardar
        estatura_metros = self.cleaned_data.get('estatura')  # Obtiene el valor en metros
        estatura_cm = int(estatura_metros * 100)  # Convierte a centímetros
        return estatura_cm

    def save(self, commit=True):
        # Guardar el objeto aspirante primero
        aspirante = super().save(commit=False)

        # Guardar el aspirante en la base de datos si commit es True
        if commit:
            aspirante.save()  # Guarda el aspirante para obtener su ID

        # Ahora puedes crear los objetos relacionados, ya que aspirante tiene un ID
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
            colonia=self.cleaned_data['colonia'],
            calle=self.cleaned_data['calle'],
        )

        Banco.objects.create(
            aspirante=aspirante,
            banco=self.cleaned_data['banco'],
            cuenta_bancaria=self.cleaned_data['cuenta_bancaria']
        )

        Participacion.objects.create(
            aspirante=aspirante,
            estado_participacion=self.cleaned_data['estado_participacion'],
            ciclo_escolar=self.cleaned_data['ciclo_escolar'],
            tipo_servicio=self.cleaned_data['Tipo_de_servicio'],
            Contexto=self.cleaned_data['Contexto'],
            programa_participacion=self.cleaned_data['programa_participacion']
        )

        # Aquí creas el objeto DocumentosPersonales y lo asocias con el aspirante
        if self.cleaned_data.get('identificacion_oficial'):
            DocumentosPersonales.objects.create(
                datos_personales=aspirante.datos_personales,
                identificacion_oficial=self.cleaned_data['identificacion_oficial'],
                comprobante_domicilio=self.cleaned_data.get('comprobante_domicilio'),
                certificado_estudio=self.cleaned_data.get('certificado_estudio')
            )

        # Si hay archivos adicionales (como fotografía), también se actualizan aquí
        if self.cleaned_data.get('fotografia'):
            aspirante.fotografia = self.cleaned_data['fotografia']
            aspirante.save()  # Guarda o actualiza la fotografía del aspirante

        return aspirante  # Devolver el aspirante guardado

