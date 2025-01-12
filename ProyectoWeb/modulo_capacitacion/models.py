from django.db import models
from login_app.models import UsuarioRol

class CapacitacionInicial(models.Model):
    cv_region = models.CharField(max_length=50)
    nombre_ecar = models.CharField(max_length=100)
    cv_microrregion = models.CharField(max_length=50)
    nombre_eca = models.CharField(max_length=100)
    cv_comunidad = models.CharField(max_length=50)
    id_ec = models.CharField(max_length=20)
    nombre_ec = models.CharField(max_length=100)
    ciclo_asignado = models.CharField(max_length=50)
    contexto = models.TextField()
    tipo_servicio = models.CharField(max_length=50)
    actividad = models.CharField(max_length=100)
    fecha = models.DateField()
    horas_cubiertas = models.PositiveIntegerField(default=0)
    cct = models.CharField(max_length=50, unique=True)
    finalizada = models.BooleanField(default=False)

    class Meta:
        verbose_name = "Capacitación Inicial"
        verbose_name_plural = "Capacitaciones Iniciales"

    def __str__(self):
        return f"{self.nombre_ec} - {self.ciclo_asignado}"
