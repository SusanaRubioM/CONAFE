from django.db import models
from django.core.validators import MinValueValidator, RegexValidator
from django.utils import timezone  # Asegúrate de importar timezone para usarlo

# Modelo para Estados
class Estado(models.Model):
    cv_estado = models.CharField(
        max_length=5,
        primary_key=True,
        verbose_name="Clave única del estado",
        validators=[RegexValidator(regex='^[A-Za-z0-9]+$', message="Solo se permiten letras y números.")]
    )
    nombre_estado = models.CharField(max_length=100, verbose_name="Nombre completo del estado")
    created_at = models.DateTimeField(verbose_name="Fecha de creación", default=timezone.now)  # Agregado default=timezone.now
    updated_at = models.DateTimeField(verbose_name="Fecha de última actualización", default=timezone.now)  # Agregado default=timezone.now

    class Meta:
        db_table = "estado"

    def __str__(self):
        return self.nombre_estado


# Modelo para Regiones
class Region(models.Model):
    cv_region = models.CharField(
        max_length=10,
        primary_key=True,
        verbose_name="Clave única de la región",
        validators=[RegexValidator(regex='^[A-Za-z0-9]+$', message="Solo se permiten letras y números.")]
    )
    nombre_region = models.CharField(max_length=100, verbose_name="Nombre completo de la región")
    estado = models.ForeignKey(Estado, on_delete=models.CASCADE, related_name="regiones", verbose_name="Estado al que pertenece", null=True, blank=True)  # Hacerlo opcional
    id_ecar = models.IntegerField(verbose_name="Identificador del responsable ECAR asignado", validators=[MinValueValidator(1)])
    created_at = models.DateTimeField(verbose_name="Fecha de creación", default=timezone.now)  # Agregado default=timezone.now
    updated_at = models.DateTimeField(verbose_name="Fecha de última actualización", default=timezone.now)  # Agregado default=timezone.now

    class Meta:
        db_table = "region"

    def __str__(self):
        return self.nombre_region


# Modelo para Microrregiones
class Microrregion(models.Model):
    cv_microrregion = models.CharField(
        max_length=20,
        primary_key=True,
        verbose_name="Clave única de la microrregión",
        validators=[RegexValidator(regex='^[A-Za-z0-9]+$', message="Solo se permiten letras y números.")]
    )
    nombre_microrregion = models.CharField(max_length=100, verbose_name="Nombre completo de la microrregión")
    region = models.ForeignKey(
        Region, 
        on_delete=models.CASCADE, 
        related_name="microrregiones", 
        verbose_name="Región a la que pertenece",
        null=True,  # Permitir que este campo sea nulo
        blank=True  # Permite que esté vacío en formularios
    )
    id_eca = models.IntegerField(verbose_name="Identificador del responsable ECA asignado", validators=[MinValueValidator(1)])
    created_at = models.DateTimeField(verbose_name="Fecha de creación", default=timezone.now)  # Agregado default=timezone.now
    updated_at = models.DateTimeField(verbose_name="Fecha de última actualización", default=timezone.now)  # Agregado default=timezone.now

    class Meta:
        db_table = "microrregion"

    def __str__(self):
        return self.nombre_microrregion


# Modelo para Comunidades
class Comunidad(models.Model):
    cv_comunidad = models.CharField(
        max_length=20,
        primary_key=True,
        verbose_name="Clave única de la comunidad",
        validators=[RegexValidator(regex='^[A-Za-z0-9]+$', message="Solo se permiten letras y números.")]
    )
    nombre_comunidad = models.CharField(max_length=100, verbose_name="Nombre completo de la comunidad")
    microrregion = models.ForeignKey(
        Microrregion,
        on_delete=models.CASCADE,
        related_name="comunidades",
        verbose_name="Microrregión a la que pertenece",
        default=1  # Valor predeterminado para microrregion
    )
    contexto = models.TextField(verbose_name="Contexto social de la comunidad")
    tipo_servicio = models.TextField(verbose_name="Tipo de servicio educativo que se ofrece")
    id_ec = models.IntegerField(verbose_name="Identificador del responsable EC asignado", validators=[MinValueValidator(1)])
    cantidad_alumnos = models.IntegerField(verbose_name="Número de alumnos en la comunidad", validators=[MinValueValidator(0)])
    estatus = models.CharField(
        max_length=8,
        choices=[('Activo', 'Activo'), ('Inactivo', 'Inactivo')],
        verbose_name="Estado actual de la comunidad"
    )
    created_at = models.DateTimeField(verbose_name="Fecha de creación", default=timezone.now, null=True, blank=True)  # Agregado default=timezone.now
    updated_at = models.DateTimeField(verbose_name="Fecha de última actualización", default=timezone.now, null=True, blank=True)  # Agregado default=timezone.now

    class Meta:
        db_table = "comunidad"

    def __str__(self):
        return self.nombre_comunidad
