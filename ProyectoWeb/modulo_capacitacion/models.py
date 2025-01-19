from django.core.exceptions import ValidationError
from django.core.validators import MinValueValidator
from django.db import models

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
        null=True,  
        blank=True  
    )
    usuario_asignada = models.ForeignKey(
        'modulo_dot.Usuario', 
        on_delete=models.CASCADE, 
        related_name='vacantes_responsables',
        limit_choices_to={'rol': 'EC'},  
        null=True, 
        blank=True
    )
    puesto = models.CharField(max_length=100)
    descripcion = models.TextField()
    fecha_asignacion = models.DateField()
    estado = models.CharField(
        max_length=20,
        choices=ESTADOS_VACANTE,
        default='pendiente'
    )
    horas_asignadas = models.PositiveIntegerField(
        default=0,
        validators=[MinValueValidator(0)]
    )
    # Campos adicionales según el formulario
    ciclo_asignado = models.CharField(max_length=20, null=True, blank=True)
    ecar = models.ForeignKey('modulo_dot.Usuario', on_delete=models.SET_NULL, null=True, blank=True, related_name='ecar_vacantes')
    ec = models.ForeignKey('modulo_dot.Usuario', on_delete=models.SET_NULL, null=True, blank=True, related_name='ec_vacantes')
    actividad = models.TextField(null=True, blank=True)
    contexto = models.TextField(null=True, blank=True)
    horas_cubiertas = models.PositiveIntegerField(default=0, validators=[MinValueValidator(0)], null=True, blank=True)
    fecha = models.DateField(null=True, blank=True)

    created_at = models.DateTimeField(auto_now_add=True, null=True, blank=True)
    updated_at = models.DateTimeField(auto_now=True, null=True, blank=True)

    class Meta:
        verbose_name = 'Vacante Asignada'
        verbose_name_plural = 'Vacantes Asignadas'
        ordering = ['-fecha_asignacion']

    def __str__(self):
        return f'Vacante: {self.puesto} asignada a {self.usuario_asignada.datos_personales} - {self.fecha_asignacion}'

    def save(self, *args, **kwargs):
        if self.usuario_asignado.rol != 'ECAR':
            raise ValidationError('El usuario seleccionado como ECAR debe tener el rol ECAR')
        
        if self.usuario_responsable.rol != 'EC':
            raise ValidationError('El usuario seleccionado como EC debe tener el rol EC')

        if self.horas_asignadas >= 240:
            self.estado = 'completada'
        elif self.horas_asignadas > 0:
            self.estado = 'en_proceso'
        
        super().save(*args, **kwargs)
