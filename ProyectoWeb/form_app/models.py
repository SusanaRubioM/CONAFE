from django.db import models
from django.core.exceptions import ValidationError
import re
from django import forms
from django.core.validators import FileExtensionValidator
from datetime import datetime

from modulo_dot.models import Usuario

# Función para validar el tamaño del archivo
def validate_file_size(file):
    max_size = 5 * 1024 * 1024  # 5 MB
    if file.size > max_size:
        raise ValidationError("El archivo es demasiado grande.")
    return file


# Función para validar el número de teléfono
def validate_phone_number(value):
    # Usamos una expresión regular para permitir solo números y, opcionalmente, un signo '+' al principio
    if not re.match(r"^\+?\d+$", value):
        raise ValidationError(
            "El número de teléfono solo debe contener números y, opcionalmente, un signo + al inicio."
        )


class Aspirante(models.Model):
    # Información personal
    folio = models.CharField(max_length=150, unique=True, blank=True, null=True)  # Folio único del aspirante
    datos_personales = models.OneToOneField(
        'modulo_dot.DatosPersonales', null=True, blank=True, on_delete=models.CASCADE
    )  # Relación uno a uno con DatosPersonales (opcional)
    status_seleccion = models.CharField(
        max_length=10, 
        choices=[      
            ('aceptado', 'aceptado'),
            ('pendiente', 'pendiente'),
            ('rechazado', 'rechazado')
        ],
        default='pendiente',  # Establecer 'pendiente' como valor por defecto
        null=True,  # Permitir valores nulos
        blank=True  # Permitir valores en blanco
    )

    usuario = models.OneToOneField('modulo_dot.Usuario', on_delete=models.CASCADE, null=True, blank=True)  # Relación uno a uno con Usuario (opcional)
    
    class Meta:
        db_table = "Aspirante"  # Definir el nombre de la tabla en minúsculas

    def asignacion_folio(self):
        year = datetime.now().year
        last_folio = (
            Aspirante.objects.filter(folio__startswith=f"ASP-{year}")
            .order_by("-folio")
            .first()
        )
        if last_folio:
            last_number = int(last_folio.folio.split("-")[-1])
            new_number = last_number + 1
        else:
            new_number = 1  # Iniciar la secuencia si no existen registros previos
        self.folio = f"ASP-{year}-{new_number:05d}"

    def save(self, *args, **kwargs):
        # Asignar folio automáticamente si el rol del usuario es "ASPIRANTE"
        if self.usuario and self.usuario.rol == "ASPIRANTE":
            if not self.folio:
                self.asignacion_folio()  # Este método ya asigna el folio directamente
        else:
            # Si no es "ASPIRANTE", asegurarse de que el folio sea nulo
            self.folio = None
            self.status_seleccion = None  # Cambiar el estado de selección a "activo"

        # Crear un usuario con rol "ASPIRANTE" solo si el usuario no existe
        if not self.usuario:
            self.usuario = Usuario.objects.create(rol="ASPIRANTE")

        super(Aspirante, self).save(*args, **kwargs)

    def __str__(self):
        # Mostrar el nombre completo si existe datos personales
        if self.datos_personales:
            return f"{self.datos_personales.nombre} {self.datos_personales.apellidopa} {self.datos_personales.apellidoma}"
        return "Aspirante sin datos personales"


class Gestion(models.Model):
    aspirante = models.OneToOneField(Aspirante, on_delete=models.CASCADE)  # Relación con Aspirante
    habla_lengua_indigena = models.BooleanField()  # (obligatorio)
    lengua_indigena = models.CharField(max_length=100, blank=True, null=True)  # opcional
    talla_playera = models.CharField(max_length=10)  # obligatorio
    talla_pantalon = models.CharField(max_length=10)  # obligatorio
    talla_calzado = models.CharField(max_length=10)  # obligatorio
    peso = models.FloatField()  # obligatorio
    estatura = models.FloatField()  # Estatura obligatorio
    medio_publicitario = models.CharField(max_length=100)

    def __str__(self):
        return f"Información de Gestión para {self.aspirante.folio}"

    class Meta:
        db_table =  "Informacion_Gestion"  # Definir el nombre de la tabla en minúsculas


class Banco(models.Model):
    aspirante = models.OneToOneField(Aspirante, on_delete=models.CASCADE)  # Relación con Aspirante
    banco = models.CharField(max_length=100, blank=True, null=True)  # Banco (opcional)
    cuenta_bancaria = models.CharField(max_length=50, blank=True, null=True)  # Cuenta bancaria (opcional)

    def __str__(self):
        return f"Información Bancaria para {self.aspirante.folio}"

    class Meta:
        db_table = "Informacion_Bancaria"  # Definir el nombre de la tabla en minúsculas


class Residencia(models.Model):
    aspirante = models.OneToOneField(Aspirante, on_delete=models.CASCADE)  # Relación con Aspirante
    codigo_postal = models.CharField(max_length=10)  # Código postal (obligatorio)
    estado = models.CharField(max_length=100)  # Estado (obligatorio)
    municipio_alcaldia = models.CharField(max_length=100)  # Municipio o Alcaldía (obligatorio)
    colonia = models.CharField(max_length=100)  # Colonia (obligatorio)
    calle = models.CharField(max_length=100)  # Calle (obligatorio)

    def __str__(self):
        return f"Información de Residencia para {self.aspirante.folio}"

    class Meta:
        db_table = "Residencia"  # Definir el nombre de la tabla en minúsculas


class Participacion(models.Model):
    aspirante = models.OneToOneField(Aspirante, on_delete=models.CASCADE)  # Relación con Aspirante
    estado_participacion = models.CharField(max_length=100)  # Estado en el que desea participar (obligatorio)
    ciclo_escolar = models.CharField(max_length=100)  # Ciclo escolar para participar (obligatorio)
    programa_participacion = models.CharField(max_length=100)  # Programa en el que desea participar (obligatorio)
    tipo_servicio = models.CharField(max_length=100)  # Tipo de servicio (obligatorio)
    contexto = models.CharField(max_length=100)  # Contexto del aspirante (obligatorio)

    def __str__(self):
        return f"Información de Participación para {self.aspirante.folio}"

    class Meta:
        db_table = "Participacion"  # Definir el nombre de la tabla en minúsculas
