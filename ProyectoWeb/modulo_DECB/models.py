from django.db import models
from django.conf import settings
from login_app.models import UsuarioRol
from django.utils import timezone


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
        ('EC_INIT', 'Educador Comunitario de Inicial'),
        ('EC', 'Educador Comunitario de Preescolar, Primaria y Secundaria'),
        ('ECA', 'Educador Comunitario de Acompañamiento'),
        ('ECAR', 'Educador Comunitario de Acompañamiento Regional'),
    ]
    
    AMAUNT_PAY = {
        'EC_INIT': 2603.00,
        'EC': 4684.00,
        'ECA': 6455.00,
        'ECAR': 8803.00
    }

    STATUS_PAYMENT = [
        ('pendiente', 'Pendiente'),
        ('procesado', 'Procesado'),
        ('rechazado', 'Rechazado'),
        ('completado', 'Completado'),
        ('completado-inicial' , 'Completado-Inicial')
    ]



    payment_date = models.DateField()
    payment_type = models.CharField(max_length=50, choices = PAYMENT_TYPES)
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
    status = models.CharField(max_length=20, choices = STATUS_PAYMENT, default='pendiente')
    signature = models.ImageField(upload_to='signatures/', blank=True, null=True)
    class Meta:
        db_table = "payment_schedule"

    def __str__(self):
        return f"{self.payment_type} - {self.payment_date} - {self.assigned_to}"
    
    def save(self, *args, **kwargs):
        """Sobrescribe el método save para calcular automáticamente el monto según el tipo de pago."""
        if self.payment_type in self.AMAUNT_PAY:
            self.amount = self.AMAUNT_PAY[self.payment_type]
        super().save(*args, **kwargs)

class PaymentStatus(models.Model):
    payment = models.OneToOneField(
        PaymentSchedule,
        on_delete=models.CASCADE,
        related_name='payment_status'
    )
    is_completed = models.BooleanField(default=False)
    completed_date = models.DateTimeField(null=True, blank=True)
    completed_by = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        related_name='completed_payments'
    )
    comments = models.TextField(blank=True)
    evidence = models.FileField(upload_to='payment_evidence/', null=True, blank=True)
    
    class Meta:
        db_table = "payment_status"
        verbose_name = "Estado de Pago"
        verbose_name_plural = "Estados de Pagos"

    def __str__(self):
        return f"Estado de pago - {self.payment}"

    def mark_as_completed(self, user, comments=""):
        self.is_completed = True
        self.completed_date = timezone.now()
        self.completed_by = user
        self.comments = comments
        self.save()
        
        # Actualizar el estado en PaymentSchedule
        self.payment.status = 'completado'
        self.payment.save()
# Historial
class PaymentHistory(models.Model):
    payment_schedule = models.ForeignKey(
        PaymentSchedule,
        on_delete=models.CASCADE,
        related_name='historial_pagos'
    )
    fecha = models.DateTimeField(auto_now_add=True)
    descripcion = models.TextField(blank=True, null=True)

    class Meta:
        db_table = "payment_history"

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
    class Meta:
        db_table = "calendar_event"
    def __str__(self):
        return f"{self.get_event_type_display()} - {self.date}"
        