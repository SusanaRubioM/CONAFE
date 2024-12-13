# models.py en modulo_dot
from django.db import models
from django.core.validators import FileExtensionValidator
from login_app.models import UsuarioRol  # Importa el modelo UsuarioRol de login_app


class Usuario(models.Model):
    usuario_rol = models.OneToOneField(UsuarioRol, null=True, blank=True, on_delete=models.CASCADE)  # Relación con UsuarioRol
    usuario = models.CharField(max_length=255, unique=True)  # Nombre de usuario en texto plano
    contrasenia = models.CharField(max_length=255)  # Contraseña en texto plano
    rol = models.CharField(
        max_length=10,
        choices=[
            ('CT', 'Coordinador Territorial'),
            ('DECB', 'Dirección de Educación Comunitaria e Inclusión Social'),
            ('DPE', 'Dirección de Planeación y Evaluación'),
            ('EC', 'Educador Comunitario'),
            ('ECA', 'Educador Comunitario de Acompañamiento Microrregional'),
            ('ECAR', 'Educador Comunitario de Acompañamiento Regional'),
            ('APEC', 'Asesor de Promoción y Educación Comunitaria'),
            ('DOT', 'Dirección de Operación Territorial'),
            ('ASPIRANTE', 'aspirante'),
        ],
        default='ASPIRANTE'
    )

    class Meta:
        db_table = 'usuario'

    def __str__(self):
        return self.usuario

    def save(self, *args, **kwargs):
        # Solo creamos UsuarioRol si no se ha creado previamente
        if not self.usuario_rol:  
            # Crear UsuarioRol asociado con este usuario
            usuario_rol = UsuarioRol.objects.create(
                username=self.usuario,  # Asignamos el nombre de usuario
                password=self.contrasenia,  # Asignamos la contraseña en texto plano
                role=self.rol  # Asignamos el rol
            )
            self.usuario_rol = usuario_rol  # Asociamos el UsuarioRol al Usuario
        super().save(*args, **kwargs)


# Modelo de Datos Personales
class DatosPersonales(models.Model):
    nombre = models.CharField(max_length=255)
    apellidopa = models.CharField(max_length=255)
    apellidoma = models.CharField(max_length=255)
    edad = models.IntegerField()
    sexo = models.CharField(
        max_length=50,
        choices=[('Masculino', 'Masculino'), ('Femenino', 'Femenino'), ('Otro', 'Otro')]
    )
    correo = models.EmailField(unique=True)
    telefono = models.CharField(max_length=50)
    formacion_academica = models.CharField(max_length=255)
    curp = models.CharField(max_length=18, unique=True)
    fotografia = models.ImageField(upload_to='fotografias_personales/', null=True, blank=True)
    usuario = models.ForeignKey(Usuario, on_delete=models.CASCADE)

    
    def save(self, *args, **kwargs):
        if DatosPersonales.objects.filter(usuario=self.usuario).exists():
            raise ValueError("Este usuario ya tiene datos personales asociados.")
        super().save(*args, **kwargs)

    class Meta:
        db_table = 'datos_personales'

    def __str__(self):
        return f"{self.nombre} {self.apellidopa} {self.apellidoma}"


# Modelo de Documentos Personales
class DocumentosPersonales(models.Model):
    datos_personales = models.ForeignKey(
        'DatosPersonales',  # Usamos 'DatosPersonales' como referencia
        related_name='documentos',
        on_delete=models.CASCADE
    )
    identificacion_oficial = models.FileField(
        upload_to='documentos_identificacion/', 
        validators=[FileExtensionValidator(allowed_extensions=['pdf', 'jpg', 'png'])],
        null=True,  # Permite que el campo sea nulo
        blank=True  # Permite que el campo esté vacío
    )
    comprobante_domicilio = models.FileField(
        upload_to='documentos_domicilio/', 
        validators=[FileExtensionValidator(allowed_extensions=['pdf', 'jpg', 'png'])],
        null=True,  # Permite que el campo sea nulo
        blank=True  # Permite que el campo esté vacío
    )
    certificado_estudio = models.FileField(
        upload_to='documentos_estudio/', 
        validators=[FileExtensionValidator(allowed_extensions=['pdf', 'jpg', 'png'])],
        null=True,  # Permite que el campo sea nulo
        blank=True  # Permite que el campo esté vacío
    )

    class Meta:
        db_table = 'documentos_personales'
        verbose_name = 'Documento Personal'
        verbose_name_plural = 'Documentos Personales'

    def __str__(self):
        return f"Documentos de {self.datos_personales.nombre} {self.datos_personales.apellidopa}"
