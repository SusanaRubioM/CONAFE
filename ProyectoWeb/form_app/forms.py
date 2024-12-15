from django import forms
#from .models import Aspirante, FormacionAcademica
#from .models import validate_phone_number  # Suponiendo que hayas definido este validador
#from django.core.validators import RegexValidator
# Lista de estados mexicanos como constante fuera de la clase
"""
ESTADOS_MEXICO = [
    ('aguascalientes', 'Aguascalientes'),
    ('baja_california', 'Baja California'),
    ('baja_california_sur', 'Baja California Sur'),
    ('campeche', 'Campeche'),
    ('chiapas', 'Chiapas'),
    ('chihuahua', 'Chihuahua'),
    ('ciudad_de_mexico', 'Ciudad de México'),
    ('coahuila', 'Coahuila'),
    ('colima', 'Colima'),
    ('durango', 'Durango'),
    ('guanajuato', 'Guanajuato'),
    ('guerrero', 'Guerrero'),
    ('hidalgo', 'Hidalgo'),
    ('jalisco', 'Jalisco'),
    ('edo_mexico', 'Estado de México'),
    ('michoacan', 'Michoacán'),
    ('morelos', 'Morelos'),
    ('nayarit', 'Nayarit'),
    ('nuevo_leon', 'Nuevo León'),
    ('oaxaca', 'Oaxaca'),
    ('puebla', 'Puebla'),
    ('queretaro', 'Querétaro'),
    ('quintana_roo', 'Quintana Roo'),
    ('san_luis_potosi', 'San Luis Potosí'),
    ('sinaloa', 'Sinaloa'),
    ('sonora', 'Sonora'),
    ('tabasco', 'Tabasco'),
    ('tamaulipas', 'Tamaulipas'),
    ('tlaxcala', 'Tlaxcala'),
    ('veracruz', 'Veracruz'),
    ('yucatan', 'Yucatán'),
    ('zacatecas', 'Zacatecas'),
]

# Lista de bancos en México (puedes agregar más según sea necesario)
BANCO_CHOICES = [
    ('BBVA', 'BBVA'),
    ('Santander', 'Santander'),
    ('Banorte', 'Banorte'),
    ('HSBC', 'HSBC'),
    ('Citibanamex', 'Citibanamex'),
    ('Scotiabank', 'Scotiabank'),
    ('Inbursa', 'Inbursa'),
    ('Bajío', 'Bajío'),
    ('Monex', 'Monex'),
    ('BancoAzteca', 'Banco Azteca'),
    ('Banregio', 'Banregio'),
    ('Compartamos', 'Compartamos'),
    ('Otros', 'Otros'),  # Opción adicional en caso de que el banco no esté en la lista
]

# Form principal
class RegistroAspiranteForm(forms.ModelForm):
    class Meta:
        model = Aspirante
        fields = ['nombre', 'apellido_paterno', 'apellido_materno', 'correo', 'telefono']
    
    telefono = forms.CharField(
        max_length=15,
        label="Número de Teléfono",
        validators=[validate_phone_number]
    )

    # Campos del modelo FormacionAcademica
    nivel_academico = forms.ChoiceField(
        choices=[
            ('1', 'Primaria'),
            ('2', 'Secundaria'),
            ('3', 'Preparatoria'),
            ('4', 'Universidad'),
            ('5', 'Maestría'),
            ('6', 'Doctorado'),
        ],
        label="Nivel Académico"
    )
    habla_lengua_indigena = forms.ChoiceField(
        choices=[('sí', 'Sí'), ('no', 'No')],
        label="¿Hablas alguna lengua indígena?",
        widget=forms.RadioSelect()
    )

    # Método para limpiar y convertir los valores a Booleano
    def clean_habla_lengua_indigena(self):
        data = self.cleaned_data['habla_lengua_indigena']
        # Convertir "sí" a True y "no" a False
        if data == 'sí':
            return True
        return False
    
    
    certificado_constancia = forms.FileField(
        label="Certificado o constancia del último grado de estudios"
    )

    # Información Adicional
    talla_playera = forms.ChoiceField(
        choices=[('S', 'S'), ('M', 'M'), ('L', 'L'), ('XL', 'XL')],
        label="Talla de Playera"
    )
    # Talla de Pantalón (del 28 al 42)
    talla_pantalon = forms.ChoiceField(
        choices=[(str(i), str(i)) for i in range(28, 43)],
        label="Talla de Pantalón"
    )
    # Talla de Calzado con números MX (por ejemplo: 24.5, 25, 25.5, etc.)
    talla_calzado = forms.ChoiceField(
        choices=[('24.5', '24.5'), ('25', '25'), ('25.5', '25.5'), ('26', '26'),
                 ('26.5', '26.5'), ('27', '27'), ('27.5', '27.5'), ('28', '28'),
                 ('28.5','28.5'), ('29','29')],
        label="Talla de Calzado (MX)"
    )
    banco = forms.ChoiceField(
        choices=BANCO_CHOICES,
        label="Banco"
    )


    cuenta_bancaria = forms.CharField(
        max_length=50,  # O el tamaño que desees
        label="Cuenta Bancaria",
        validators=[RegexValidator(r'^[0-9]+$', 'Solo se permiten números en la cuenta bancaria')]
    )

    # Residencia
    codigo_postal = forms.CharField(
        max_length=5,  # O el tamaño que desees
        label="Codigo Postal",
        validators=[RegexValidator(r'^[0-9]+$', 'Solo se permiten números')]
    )
    estado = forms.ChoiceField(
        choices=ESTADOS_MEXICO,
        label="Estado",
    )
    municipio = forms.CharField(max_length=100, label="Municipio o Alcaldía")
    localidad = forms.CharField(max_length=100, label="Localidad")
    colonia = forms.CharField(max_length=100, label="Colonia")

    # Participación
    estado_participacion = forms.ChoiceField(
        choices=ESTADOS_MEXICO,
        label="Estado en el que deseas participar"
    )
    ciclo_escolar = forms.ChoiceField(
    choices=[('2025-2026','2025-2026'), ('2026-2027','2026-2027')]
    )

    # Documentos
    identificacion_oficial = forms.FileField(label="Identificación oficial")
    fotografia = forms.FileField(label="Fotografía reciente")
    comprobante_domicilio = forms.FileField(label="Comprobante de domicilio")


    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        for field in self.fields.values():
            if isinstance(field.widget, forms.widgets.FileInput):
                field.widget.attrs.update({'class': 'form-control-file'})
            elif isinstance(field.widget, forms.widgets.RadioSelect):
                field.widget.attrs.update({'class': 'form-check-input'})
            else:
                field.widget.attrs.update({'class': 'form-control'})

"""





