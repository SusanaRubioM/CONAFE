# models.py en login_app
from django.contrib.auth.models import AbstractBaseUser, BaseUserManager
from django.db import models
from django.contrib.auth.hashers import make_password

class UsuarioRolManager(BaseUserManager):
    def create_user(self, username, password=None, **extra_fields):
        if not username:
            raise ValueError('El usuario debe tener un nombre de usuario')

        extra_fields.setdefault('is_active', True)

        # Crear el usuario sin encriptar la contraseña
        user = self.model(username=username, **extra_fields)
        user.set_password(password)  # Encriptar la contraseña
        user.save(using=self._db)  # Guardar el usuario en la base de datos
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
        ]
    )

    USERNAME_FIELD = 'username'
    REQUIRED_FIELDS = ['email']

    objects = UsuarioRolManager()  # Usando el manager personalizado

    class Meta:
        db_table = 'Usuario_rol'

    def __str__(self):
        return self.username

    def save(self, *args, **kwargs):
        if self.password and not self.password.startswith('$'):
            self.password = make_password(self.password)  # Encriptar la contraseña
        super().save(*args, **kwargs)