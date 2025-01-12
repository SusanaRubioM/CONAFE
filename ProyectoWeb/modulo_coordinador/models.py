from django.db import models
import os
from django.apps import apps
from django.core.exceptions import ValidationError
from modulo_apec.models import Estado, Region, Microrregion
from django.core.validators import MinValueValidator, RegexValidator

class ConveniosFiguras(models.Model):
    usuario = models.OneToOneField('modulo_dot.Usuario', on_delete=models.CASCADE, null=True, blank=True)
    convenio_pdf = models.FileField(upload_to='documentos/', null=True, blank=True)
    firma_digital = models.FileField(upload_to='firmas/', null=True, blank=True)

    class Meta:
        db_table = "convenio_digital"

    def __str__(self):
        return f"Convenio de {self.usuario.usuario} ({self.pk})"

    def save(self, *args, **kwargs):
        # Asigna el archivo predeterminado si no se ha asignado
        if not self.convenio_pdf:
            self.convenio_pdf = os.path.join('documentos', 'Convenio_figuras.pdf')
        super().save(*args, **kwargs)

class ActividadCalendario(models.Model):
    titulo = models.CharField(max_length=200)
    descripcion = models.TextField(blank=True, null=True)
    fecha_inicio = models.DateTimeField()
    fecha_fin = models.DateTimeField()

    def clean(self):
        if self.fecha_inicio >= self.fecha_fin:
            raise ValidationError("La fecha de inicio debe ser menor que la fecha de fin.")

    def save(self, *args, **kwargs):
        self.clean()
        super().save(*args, **kwargs)

    class Meta:
        db_table = "actividad_calendario"

    def __str__(self):
        return self.titulo


#class Municipio(models.Model):
#    clave = models.CharField(max_length=3)
 #   nombre = models.CharField(max_length=100)
  #  estado = models.ForeignKey(Estado, on_delete=models.CASCADE)







