from django.db import models
from django.conf import settings

# Create your models here.
class ResultadosConvocatoria(models.Model):
    archivo = models.FileField(upload_to='convocatoria/', null=True, blank=True) # Ruta del archivo en el sistem
    fecha_subida = models.DateTimeField(auto_now_add=True)  # Fecha y hora de la subida
    subido_por = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        related_name='archivos_subidos',
        on_delete=models.CASCADE
    )

    class Meta:
        db_table = "resultados_convocatorias"

    def __str__(self):
        return self.archivo