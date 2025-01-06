from django.db import models
import os
from django.apps import apps

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
