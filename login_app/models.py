from django.contrib.auth.models import AbstractBaseUser, BaseUserManager
from django.db import models
from django.contrib.auth.hashers import make_password


# Definir el manager del modelo de usuario para crear usuarios
class UsuarioRolManager(BaseUserManager):
    def create_user(self, username, password=None, **extra_fields):
        if not username:
            raise ValueError("El usuario debe tener un nombre de usuario")

        extra_fields.setdefault('is_active', True)

        user = self.model(username=username, **extra_fields)
        
        # Si se proporciona una contraseña, la encriptamos
        if password:
            user.set_password(password)
        user.save(using=self._db)
        return user

    def create_superuser(self, username, password=None, **extra_fields):
        extra_fields.setdefault('is_staff', True)
        extra_fields.setdefault('is_superuser', True)

        return self.create_user(username, password, **extra_fields)


# Modelo de usuario con roles
class UsuarioRol(AbstractBaseUser):
    username = models.CharField(max_length=150, unique=True, null=True, blank=True)
    first_name = models.CharField(max_length=150, null=True, blank=True)
    last_name = models.CharField(max_length=150, null=True, blank=True)
    email = models.EmailField(max_length=254, null=True, blank=True)
    
    # No usamos null=True aquí, ya que la contraseña debe estar encriptada
    password = models.CharField(max_length=255, null=True, blank=True)  # Permitir password vacío (no null)
    
    is_staff = models.BooleanField(default=False)
    is_active = models.BooleanField(default=True)
    is_superuser = models.BooleanField(default=False)
    date_joined = models.DateTimeField(auto_now_add=True)
    role = models.CharField(
        max_length=10,
        choices=[  
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

    USERNAME_FIELD = 'username'
    REQUIRED_FIELDS = ['email']

    objects = UsuarioRolManager()

    class Meta:
        db_table = 'Usuario_rol'

    def __str__(self):
        return self.username


# Modelo de Status, para indicar el estado de un usuario
class Statuses(models.Model):
    usuario = models.OneToOneField('modulo_dot.Usuario', null=True, blank=True, on_delete=models.CASCADE)
    status = models.CharField(
        max_length=15,  
        choices=[('activa', 'Activa'),
                 ('baja', 'Baja'),
                 ('reincorporacion', 'Reincorporación'),
                 ('reingreso', 'Reingreso'),
                 ('suspendida', 'Suspendida'),
                 ('capacitacion', 'Capacitacion')],
        default='suspendida'  
    )
    class Meta:
        db_table = "Statuses"

    def __str__(self):
        return self.usuario.username if self.usuario else 'No Usuario'


