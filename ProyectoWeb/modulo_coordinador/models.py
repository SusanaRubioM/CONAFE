from django.db import models
import os
import datetime
from django.apps import apps
from django.core.exceptions import ValidationError
from datetime import datetime

class ConveniosFiguras(models.Model):
    control_numero = models.CharField(max_length=150, unique=True, blank=True, null=True)
    usuario = models.OneToOneField('modulo_dot.Usuario', on_delete=models.CASCADE, null=True, blank=True)  # Usuario destinatario del convenio
    convenio_pdf = models.FileField(upload_to='documentos/', null=True, blank=True)
    firma_digital = models.FileField(upload_to='firmas/', null=True, blank=True)
    estado_convenio = models.CharField(max_length=50,
                                       choices=[('Pendiente', 'Pendiente'),
                                                ('Aprobado', 'Aprobado'),
                                                ('Rechazado', 'Rechazado')],
                                       default='Pendiente')
    tipo_convenio = models.CharField(max_length=50,
                                     choices=[('CUD', 'CUD'),
                                              ('Inicial', 'Inicial'),
                                              ('Otro', 'Rechazado')],
                                     default='Inicial')
    firmado_por = models.ForeignKey('modulo_dot.Usuario', related_name="firmado_por", null=True, blank=True, on_delete=models.SET_NULL)  # El usuario que firma el convenio

    class Meta:
        db_table = "convenio_digital"

    def numero_control(self):
        year = datetime.now().year
        year_short = str(year)[2:]  # Obtiene los dos últimos dígitos del año
        identifier = 'EB'  # Identificador de convenio
        last_folio = (
            ConveniosFiguras.objects.filter(control_numero__startswith=f"{year_short}{identifier}")
            .order_by("-control_numero")
            .first()
        )
        if last_folio:
            last_number = int(last_folio.control_numero[-6:])  # Obtiene los últimos 6 dígitos
            new_number = last_number + 1
        else:
            new_number = 1  # Iniciar la secuencia si no existen registros previos

        new_number_str = str(new_number).zfill(6)  # Asegura que el número tenga 6 dígitos
        self.control_numero = f"{year_short}{identifier}{new_number_str}"

    def __str__(self):
        return f"Convenio de {self.usuario.usuario} ({self.pk})"

    def save(self, *args, **kwargs):
        # Asigna el archivo predeterminado si no se ha asignado
        if not self.convenio_pdf:
            self.convenio_pdf = os.path.join('documentos', 'Convenio_figuras.pdf')

        # Llama al método de generar el número de control antes de guardar
        if not self.control_numero:
            self.numero_control()

        # Lógica de actualización del estado basado en la firma digital
        if self.firma_digital and self.firma_digital.name.strip():  # Si hay firma digital válida
            if self.estado_convenio != 'Aprobado':
                self.estado_convenio = 'Aprobado'
        else:
            if self.estado_convenio != 'Pendiente':
                self.estado_convenio = 'Pendiente'

        # Asegúrate de que el usuario que firma el convenio se asigna correctamente
        if not self.firmado_por and self.usuario:
            self.firmado_por = self.usuario

        # Guarda el objeto
        super().save(*args, **kwargs)
