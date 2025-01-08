from django.db import models
from django.conf import settings
from login_app.models import UsuarioRol


class PaymentSchedule(models.Model):
    PAYMENT_TYPES = [
        ('movilidad', 'Movilidad'),
        ('hospedaje', 'Hospedaje y alimentos para la formación'),
        ('continuidad', 'Continuidad de estudios'),
        ('conectividad', 'Conectividad móvil'),
        ('vestuario', 'Vestuario de identidad'),
        ('atencion_medica', 'Atención médica'),
        ('fin_de_año', 'Apoyo económico de fin de año'),
        ('fallecimiento', 'Apoyo a beneficiarios por fallecimiento'),
    ]

    payment_date = models.DateField()
    payment_type = models.CharField(max_length=50, choices=PAYMENT_TYPES)
    amount = models.DecimalField(max_digits=10, decimal_places=2, default=0.0)
    assigned_to = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        related_name='payments_assigned_to',
        on_delete=models.CASCADE
    )
    assigned_by = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        related_name='payments_assigned_by',
        on_delete=models.CASCADE
    )
    status = models.CharField(max_length=20, default='pendiente')
    signature = models.ImageField(upload_to='signatures/', blank=True, null=True)

    def __str__(self):
        return f"{self.payment_type} - {self.payment_date} - {self.assigned_to}"

class PaymentHistory(models.Model):
    payment_schedule = models.ForeignKey(
        PaymentSchedule,
        on_delete=models.CASCADE,
        related_name='historial_pagos'
    )
    fecha = models.DateTimeField(auto_now_add=True)
    descripcion = models.TextField(blank=True, null=True)

    def __str__(self):
        return f"Historial - {self.payment_schedule.payment_type} - {self.fecha}"

class CalendarEvent(models.Model):
    EVENT_TYPES = [
        ('inicio_ciclo', 'Inicio de Ciclo Escolar'),
        ('termino_ciclo', 'Término de Ciclo Escolar'),
        ('colegiado_regional', 'Colegiado Regional'),
        ('colegiado_microrregional', 'Colegiado Microrregional'),
        ('promocion_captacion', 'Promoción y Captación'),
        ('capacitacion', 'Capacitación'),
    ]

    event_type = models.CharField(max_length=50, choices=EVENT_TYPES)
    date = models.DateField()
    description = models.TextField(blank=True)

    def __str__(self):
        return f"{self.get_event_type_display()} - {self.date}"