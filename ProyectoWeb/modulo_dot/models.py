from django.db import models
from login_app.models import UsuarioRol  # Importa el modelo relacionado

class Empleado(models.Model):
    nombre = models.CharField(max_length=150)
    apellidopa = models.CharField(max_length=150)
    apellidoma = models.CharField(max_length=150)
    email = models.EmailField(max_length=254)
    edad = models.IntegerField()
    genero = models.CharField(
        max_length=10,
        choices=[('Masculino', 'Masculino'), ('Femenino', 'Femenino'), ('Otro', 'Otro')]
    )
    salario = models.DecimalField(max_digits=10, decimal_places=2)
    foto = models.ImageField(upload_to='fotos_empleados/', null=True, blank=True)
    rol = models.CharField(
        max_length=10,
        choices=[
            ('DOT', 'Director de Operaciones y Tecnología'),
            ('CT', 'Coordinador Territorial'),
            ('EC', 'Educador Comunitario'),
            ('ECA', 'Educador Comunitario de Acompañamiento Microrregional'),
            ('ECAR', 'Educador Comunitario de Acompañamiento Regional'),
            ('APEC', 'Asesor de Promoción y Educación Comunitaria'),
            ('DEP', 'Desarrollo Educativo Profesional')
        ]
    )

    # Campo para la contraseña en texto claro
    contrasenia = models.CharField(max_length=150, null=True, blank=True)

    # Relación uno a uno con UsuarioRol (el modelo de autenticación)
    usuario = models.OneToOneField(
        UsuarioRol, on_delete=models.CASCADE, related_name='empleado'
    )

    class Meta:
        db_table = 'empleados'  # Nombre personalizado para la tabla

    def __str__(self):
        return f"{self.nombre} {self.apellidopa} {self.apellidoma} - {self.rol}"



