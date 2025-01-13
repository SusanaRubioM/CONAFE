# models.py
from django.db import models
from modulo_dot.models import Usuario, DatosPersonales
from django.core.validators import MinValueValidator
from django.core.exceptions import ValidationError

class CapacitacionInicial(models.Model):
    ESTADOS_CAPACITACION = [
        ('pendiente', 'Pendiente'),
        ('en_curso', 'En Curso'),
        ('completada', 'Completada'),
        ('cancelada', 'Cancelada')
    ]

    ecar = models.ForeignKey(
        Usuario, 
        on_delete=models.CASCADE, 
        related_name='capacitaciones_como_ecar',
        limit_choices_to={'rol': 'ECAR'},
        null=True,  # Permitir valores NULL
        blank=True  # Opcional en formularios
    )
    ec = models.ForeignKey(
        Usuario, 
        on_delete=models.CASCADE, 
        related_name='capacitaciones_como_ec',
        limit_choices_to={'rol': 'EC'}, null=True, blank=True
    )
    ciclo_asignado = models.CharField(max_length=20)
    fecha = models.DateField()
    contexto = models.TextField()
    actividad = models.TextField()
    estado = models.CharField(
        max_length=20,
        choices=ESTADOS_CAPACITACION,
        default='pendiente'
    )
    horas_cubiertas = models.PositiveIntegerField(
        default=0,
        validators=[MinValueValidator(0)]
    )
    created_at = models.DateTimeField(auto_now_add=True, null=True, blank=True)
    updated_at = models.DateTimeField(auto_now=True, null=True, blank=True)

    class Meta:
        verbose_name = 'Capacitación Inicial'
        verbose_name_plural = 'Capacitaciones Iniciales'
        ordering = ['-fecha']

    def __str__(self):
        return f'Capacitación de {self.ec.datos_personales} por {self.ecar.datos_personales} - {self.fecha}'

    def save(self, *args, **kwargs):
        # Validar que el ECAR tenga el rol correcto
        if self.ecar.rol != 'ECAR':
            raise ValidationError('El usuario seleccionado como ECAR debe tener el rol ECAR')
        
        # Validar que el EC tenga el rol correcto
        if self.ec.rol != 'EC':
            raise ValidationError('El usuario seleccionado como EC debe tener el rol EC')

        # Actualizar estado basado en horas cubiertas
        if self.horas_cubiertas >= 240:
            self.estado = 'completada'
        elif self.horas_cubiertas > 0:
            self.estado = 'en_curso'
        
        super().save(*args, **kwargs)