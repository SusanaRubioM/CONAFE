from django.contrib.auth.models import AbstractBaseUser, BaseUserManager
from django.db import models

class UsuarioRolManager(BaseUserManager):
    def create_user(self, username, password=None, **extra_fields):
        """
        Crea y retorna un usuario normal con username y password.
        """
        if not username:
            raise ValueError('El usuario debe tener un nombre de usuario')

        # Asegurarse de que is_active esté configurado por defecto
        extra_fields.setdefault('is_active', True)

        # Crear el usuario sin encriptar la contraseña
        user = self.model(username=username, **extra_fields)
        user.set_password(password)  # Encriptar la contraseña
        user.save(using=self._db)  # Guardar el usuario en la base de datos
        return user

    def create_superuser(self, username, password=None, **extra_fields):
        """
        Crea y retorna un superusuario.
        """
        extra_fields.setdefault('is_staff', True)  # El superusuario debe ser un miembro del staff
        extra_fields.setdefault('is_superuser', True)  # El superusuario debe ser un superusuario

        return self.create_user(username, password, **extra_fields)


class UsuarioRol(AbstractBaseUser):
    username = models.CharField(max_length=150, unique=True)
    first_name = models.CharField(max_length=150, null=True, blank=True)
    last_name = models.CharField(max_length=150, null=True, blank=True)
    email = models.EmailField(max_length=254, null=True, blank=True)
    is_staff = models.BooleanField(default=False)  # Para saber si el usuario es parte del staff
    is_active = models.BooleanField(default=True)
    is_superuser = models.BooleanField(default=False)  # Agregar este campo para el superusuario
    date_joined = models.DateTimeField(auto_now_add=True)
    role = models.CharField(
        max_length=10, 
        choices=[
            ('ADMIN', 'ADMIN'),
            ('DOT', 'Director de Operaciones y Tecnología'),
            ('CT', 'Coordinador Territorial'),
            ('EC', 'Educador Comunitario'),
            ('ECA', 'Educador Comunitario de Acompañamiento Microrregional'),
            ('ECAR', 'Educador Comunitario de Acompañamiento Regional'),
            ('APEC', 'Asesor de Promoción y Educación Comunitaria'),
            ('DEP', 'Desarrollo Educativo Profesional')
        ], 
        default='EC'
    )

    USERNAME_FIELD = 'username'
    REQUIRED_FIELDS = ['email']

    objects = UsuarioRolManager()  # Asignar el manager personalizado

    class Meta:
        db_table = 'Usuario_rol'

    def __str__(self):
        return self.username
