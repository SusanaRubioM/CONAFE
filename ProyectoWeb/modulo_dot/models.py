from django.db import models
from django.core.validators import FileExtensionValidator
from login_app.models import UsuarioRol  # Importa el modelo UsuarioRol de login_app
from django.contrib.auth.hashers import make_password
from login_app.models import UsuarioRol  # Lo importamos localmente dentro de save
class Usuario(models.Model):
    usuario_rol = models.OneToOneField(UsuarioRol, null=True, blank=True, on_delete=models.SET_NULL)
    usuario = models.CharField(max_length=255, unique=True,null=True, blank=True)
    contrasenia = models.CharField(max_length=255,null=True, blank=True)  # Contraseña en texto plano
    rol = models.CharField(
        max_length=10,
        choices=[  # Lista de roles
            ("CT", "Coordinador Territorial"),
            ("DECB", "Dirección de Educación Comunitaria e Inclusión Social"),
            ("DPE", "Dirección de Planeación y Evaluación"),
            ("EC", "Educador Comunitario"),
            ("ECA", "Educador Comunitario de Acompañamiento Microrregional"),
            ("ECAR", "Educador Comunitario de Acompañamiento Regional"),
            ("APEC", "Asesor de Promoción y Educación Comunitaria"),
            ("DOT", "Dirección de Operación Territorial"),
            ("ASPIRANTE", "aspirante"),
        ],
        default="ASPIRANTE",
    )

    def save(self, *args, **kwargs):
        # Si los campos 'usuario' y 'rol' no son obligatorios, omite la validación
        if self.usuario is not None and self.rol is not None:
            if not self.usuario or not self.rol:
                raise ValueError("El campo 'usuario' y 'rol' no pueden estar vacíos.")
        
        # Si no hay un 'usuario_rol' asignado, crearlo antes de continuar
        if not self.usuario_rol:  # Verificamos si la relación ya está asignada
            if self.usuario and self.rol:  # Solo crear el rol si usuario y rol no están vacíos
                usuario_rol = UsuarioRol.objects.create(
                    username=self.usuario,
                    role=self.rol,
                    password=make_password(self.contrasenia)  # Encriptamos la contraseña
                )
                self.usuario_rol = usuario_rol  # Asignamos la relación

        # Guardamos el Usuario en la base de datos
        super().save(*args, **kwargs)
    class Meta:
        db_table = "usuario"

    def __str__(self):
        return f"{self.usuario} - {self.rol}"

    class Meta:
        db_table = "usuario"

    def __str__(self):
        return f"{self.usuario} - {self.rol}"


# Modelo de Datos Personales
class DatosPersonales(models.Model):
    nombre = models.CharField(max_length=255)
    apellidopa = models.CharField(max_length=255)
    apellidoma = models.CharField(max_length=255)
    edad = models.IntegerField()
    sexo = models.CharField(
        max_length=50,
        choices=[ 
            ("Masculino", "Masculino"),
            ("Femenino", "Femenino"),
            ("Otro", "Otro"),
        ],
    )
    correo = models.EmailField(unique=True)
    telefono = models.CharField(max_length=50)
    formacion_academica = models.CharField(max_length=255)
    curp = models.CharField(max_length=18, unique=True)
    fotografia = models.ImageField(
        upload_to="fotografias_personales/", null=True, blank=True
    )

    usuario = models.ForeignKey(Usuario, on_delete=models.CASCADE, null=True, blank=True)  # Relación OneToOne con Usuario

    def save(self, *args, **kwargs):
        # Asegurarse de que no existan datos personales asociados al usuario
        #if DatosPersonales.objects.filter(usuario=self.usuario).exists():
           # raise ValueError("Este usuario ya tiene datos personales asociados.")
        super().save(*args, **kwargs)

    class Meta:
        db_table = "datos_personales"

    def __str__(self):
        return f"{self.nombre} {self.apellidopa} {self.apellidoma}"


# Modelo de Documentos Personales
class DocumentosPersonales(models.Model):
    datos_personales = models.OneToOneField(
        "DatosPersonales",  # Usamos 'DatosPersonales' como referencia
        related_name="documentos",
        on_delete=models.CASCADE,
    )
    identificacion_oficial = models.FileField(
        upload_to="documentos_identificacion/",
        validators=[FileExtensionValidator(allowed_extensions=["pdf", "jpg", "png"])],
        null=True,  # Permite que el campo sea nulo
        blank=True,  # Permite que el campo esté vacío
    )
    comprobante_domicilio = models.FileField(
        upload_to="documentos_domicilio/",
        validators=[FileExtensionValidator(allowed_extensions=["pdf", "jpg", "png"])],
        null=True,  # Permite que el campo sea nulo
        blank=True,  # Permite que el campo esté vacío
    )
    certificado_estudio = models.FileField(
        upload_to="documentos_estudio/",
        validators=[FileExtensionValidator(allowed_extensions=["pdf", "jpg", "png"])],
        null=True,  # Permite que el campo sea nulo
        blank=True,  # Permite que el campo esté vacío
    )

    class Meta:
        db_table = "documentos_personales"
        verbose_name = "Documento Personal"
        verbose_name_plural = "Documentos Personales"

    def __str__(self):
        return f"Documentos de {self.datos_personales.nombre} {self.datos_personales.apellidopa}"

