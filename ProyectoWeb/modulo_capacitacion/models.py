from django.db import models
from django.core.validators import MinValueValidator

class VacanteAsignada(models.Model):
    ESTADOS_VACANTE = [
        ('pendiente', 'Pendiente'),
        ('Proceso', 'Proceso'),
        ('completada', 'Completada'),
        ('cancelada', 'Cancelada')
    ]
    
    usuario_responsable = models.ForeignKey(
        'modulo_dot.Usuario', 
        on_delete=models.CASCADE, 
        related_name='vacantes_asignadas',
        limit_choices_to={'rol': 'ECAR'},  
        null=True,  # Permitir NULL
        blank=True  # Permitir vacío en formularios
    )
    usuario_eca = models.ForeignKey(
        'modulo_dot.Usuario', 
        on_delete=models.CASCADE, 
        related_name='vacantes_eca',
        limit_choices_to={'rol': 'ECA'},  
        null=True,  # Permitir NULL
        blank=True  # Permitir vacío en formularios
    )
    usuario_ec = models.ForeignKey(
        'modulo_dot.Usuario', 
        on_delete=models.CASCADE, 
        related_name='vacantes_ec',
        limit_choices_to={'rol': 'EC'},  
        null=True,  # Permitir NULL
        blank=True  # Permitir vacío en formularios
    )
    vacante_asignada = models.CharField(
        max_length=255, 
        blank=True,  # Permitir vacío
        null=True  # Permitir NULL
    )
    horas_cubiertas = models.IntegerField(
        validators=[MinValueValidator(1)],
        help_text="Horas totales cubiertas de la capacitación",
        null=True,  # Permitir NULL
        blank=True  # Permitir vacío en formularios
    )
    estado = models.CharField(
        max_length=20, 
        choices=ESTADOS_VACANTE, 
        default='pendiente', 
        null=True,  # Permitir NULL
        blank=True  # Permitir vacío en formularios
    )

    contexto = models.CharField(
        max_length=100, 
        null=True,  # Permitir NULL
        blank=True  # Permitir vacío en formularios
    )
    actividad = models.CharField(
        max_length=100, 
        null=True,  # Permitir NULL
        blank=True  # Permitir vacío en formularios
    )
    ciclo_asignado = models.DateField(
        null=True,  # Permitir NULL
        blank=True  # Permitir vacío en formularios
    )
    fecha = models.DateTimeField(
        null=True,  # Permitir NULL
        blank=True  # Permitir vacío en formularios
    )


    class Meta:
        verbose_name = 'Vacante Asignada'
        verbose_name_plural = 'Vacantes Asignadas'

    def __str__(self):
        return f"{self.vacante_asignada} ({self.estado})"
