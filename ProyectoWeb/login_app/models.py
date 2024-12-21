from django.contrib.auth.models import AbstractBaseUser, BaseUserManager
from django.db import models
from django.contrib.auth.hashers import make_password

# En login_app/models.py
class UsuarioRolManager(BaseUserManager):
    def create_user(self, username, password=None, **extra_fields):
        if not username:
            raise ValueError("El usuario debe tener un nombre de usuario")

        extra_fields.setdefault('is_active', True)

        user = self.model(username=username, **extra_fields)
        user.set_password(password)  # Encriptar la contraseña
        user.save(using=self._db)
        return user

    def create_superuser(self, username, password=None, **extra_fields):
        extra_fields.setdefault('is_staff', True)
        extra_fields.setdefault('is_superuser', True)

        return self.create_user(username, password, **extra_fields)

class UsuarioRol(AbstractBaseUser):
    username = models.CharField(max_length=150, unique=True)
    first_name = models.CharField(max_length=150, null=True, blank=True)
    last_name = models.CharField(max_length=150, null=True, blank=True)
    email = models.EmailField(max_length=254, null=True, blank=True)
    is_staff = models.BooleanField(default=False)
    is_active = models.BooleanField(default=True)
    is_superuser = models.BooleanField(default=False)
    date_joined = models.DateTimeField(auto_now_add=True)
    role = models.CharField(
        max_length=10,
        choices=[('ADMIN', 'ADMIN'), ('DOT', 'Director de Operaciones y Tecnología'), 
                 ('CT', 'Coordinador Territorial'), ('EC', 'Educador Comunitario'),
                 ('ECA', 'Educador Comunitario de Acompañamiento Microrregional'),
                 ('ECAR', 'Educador Comunitario de Acompañamiento Regional'),
                 ('APEC', 'Asesor de Promoción y Educación Comunitaria'),
                 ('DEP', 'Desarrollo Educativo Profesional')],
        default='EC'
    )

    USERNAME_FIELD = 'username'
    REQUIRED_FIELDS = ['email']

    objects = UsuarioRolManager()

    class Meta:
        db_table = 'Usuario_rol'

    def __str__(self):
        return self.username

# Modificación para evitar importación circular
class Status(models.Model):
    usuario = models.OneToOneField('modulo_dot.Usuario', null=True, blank=True, on_delete=models.CASCADE)
    estado = models.CharField(
        max_length=10,
        choices=[('activo', 'activo'), ('pendiente', 'pendiente'), ('rechazado', 'rechazado')]
    )

    class Meta:
        db_table = "Status"

    def __str__(self):
        return self.usuario.usuario

