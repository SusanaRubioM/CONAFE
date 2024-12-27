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
        # Validar solo si el rol no es "ASPIRANTE"
        if self.rol != "ASPIRANTE":
            if not self.usuario or not self.contrasenia:
                raise ValueError("Los campos 'usuario' y 'contrasenia' son obligatorios para roles distintos de 'ASPIRANTE'.")

        # Si el rol es "ASPIRANTE", no asignar username ni password
        if self.rol == "ASPIRANTE":
            self.usuario = None
            self.contrasenia = None
            if not self.usuario_rol:
                self.usuario_rol = UsuarioRol.objects.create(
                    username=None,
                    role=self.rol,
                    password=None,
                )
        else:
            # Crear `usuario_rol` solo si no existe
            if not self.usuario_rol:
                self.usuario_rol = UsuarioRol.objects.create(
                    username=self.usuario,
                    role=self.rol,
                    password=make_password(self.contrasenia),
                )

        super().save(*args, **kwargs)

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

    usuario = models.OneToOneField(Usuario, on_delete=models.CASCADE)  # Relación OneToOne con Usuario

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

