from django import forms
from .models import Usuario, DatosPersonales, DocumentosPersonales

class UsuarioForm(forms.ModelForm):
    class Meta:
        model = Usuario
        fields = ['usuario', 'contrasenia']

    usuario = forms.CharField(
        max_length=255,
        required=True,
        label="Nombre de Usuario",
        widget=forms.TextInput(attrs={'class': 'form-control', 'placeholder': 'Nombre de Usuario'})
    )
    contrasenia = forms.CharField(
        widget=forms.PasswordInput(attrs={'class': 'form-control', 'placeholder': 'Contraseña'}),
        min_length=8,
        required=True,
        label="Contraseña"
    )

class DatosPersonalesForm(forms.ModelForm):
    class Meta:
        model = DatosPersonales
        fields = ['nombre', 'apellidopa', 'apellidoma', 'edad', 'sexo', 'correo', 'telefono', 
                  'formacion_academica', 'curp', 'fotografia']

    nombre = forms.CharField(
        max_length=255,
        required=True,
        label="Nombre",
        widget=forms.TextInput(attrs={'class': 'form-control', 'placeholder': 'Nombre del Usuario'})
    )
    apellidopa = forms.CharField(
        max_length=255,
        required=True,
        label="Apellido Paterno",
        widget=forms.TextInput(attrs={'class': 'form-control', 'placeholder': 'Apellido Paterno'})
    )
    apellidoma = forms.CharField(
        max_length=255,
        required=True,
        label="Apellido Materno",
        widget=forms.TextInput(attrs={'class': 'form-control', 'placeholder': 'Apellido Materno'})
    )

    EDADES_CHOICES = [(i, str(i)) for i in range(18, 50)]  # Opciones de edad de 18 a 99

    edad = forms.ChoiceField(
        choices=EDADES_CHOICES,
        required=True,
        label="Edad",
        widget=forms.Select(attrs={'class': 'form-control'})
    )

    sexo = forms.ChoiceField(
        choices=[('Masculino', 'Masculino'), ('Femenino', 'Femenino'), ('Otro', 'Otro')],
        required=True,
        label="Género",
        widget=forms.RadioSelect(attrs={'class': 'form-check-input'})
    )
    correo = forms.EmailField(
        required=True,
        label="Correo Electrónico",
        widget=forms.EmailInput(attrs={'class': 'form-control', 'placeholder': 'Correo Electrónico'})
    )
    telefono = forms.CharField(
        max_length=50,
        required=True,
        label="Teléfono",
        widget=forms.TextInput(attrs={'class': 'form-control', 'placeholder': 'Teléfono del Usuario'})
    )

    formacion_academica_CHOICE = [
    ('preparatoria', 'Preparatoria'),
    ('tecnica', 'Tecnica'),
    ('universidad', 'Universidad'),
    ]
    
    formacion_academica = forms.ChoiceField(

    choices=formacion_academica_CHOICE,  # Opciones definidas en formacion_academica_CHOICE
    required=True,
    label="Formación Académica",
    widget=forms.Select(attrs={'class': 'form-control', 'placeholder': 'Formación Académica'})  # Usar Select en lugar de TextInput
    )
    
    curp = forms.CharField(
        max_length=18,
        required=True,
        label="CURP",
        widget=forms.TextInput(attrs={'class': 'form-control', 'placeholder': 'CURP del Usuario'})
    )
    fotografia = forms.ImageField(
        required=False,
        label="Foto del Usuario",
        widget=forms.ClearableFileInput(attrs={'class': 'form-control-file'})
    )

class DocumentosPersonalesForm(forms.ModelForm):
    class Meta:
        model = DocumentosPersonales
        fields = ['identificacion_oficial', 'comprobante_domicilio', 'certificado_estudio']

    identificacion_oficial = forms.FileField(required=True, label="Identificación Oficial")
    comprobante_domicilio = forms.FileField(required=True, label="Comprobante de Domicilio")
    certificado_estudio = forms.FileField(required=True, label="Certificado de Estudio")

