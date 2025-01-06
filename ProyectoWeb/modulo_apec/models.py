from django.db import models
from django.core.validators import MinValueValidator, RegexValidator
from django.utils import timezone  # Asegúrate de importar timezone para usarlo
from django.db import models
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
    usuario = models.OneToOneField('modulo_dot.Usuario', on_delete=models.CASCADE, null=True, blank=True)
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
    usuario = models.OneToOneField('modulo_dot.Usuario', on_delete=models.CASCADE, null=True, blank=True)
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
    contexto_comunidad = models.CharField(
        max_length=255,
        choices=[
            ('Sin asignar', 'Sin asignar'),
            ('Indígena', 'Indígena'),
            ('Mestizo', 'Mestizo'),
            ('Migrante', 'Migrante'),
            ('Circense', 'Circense'),
            ('Grupos Vulnerables', 'Grupos Vulnerables'),
            ('Excluidos del Sistema Regular', 'Excluidos del Sistema Regular')
        ], default='Sin asignar'
    )
    tipo_servicio = models.TextField(verbose_name="Tipo de servicio educativo que se ofrece")
    usuario = models.OneToOneField('modulo_dot.Usuario', on_delete=models.CASCADE, null=True, blank=True)
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


class ApoyoGestion(models.Model):
    usuario = models.OneToOneField('modulo_dot.Usuario', on_delete=models.CASCADE, null=True, blank=True)
    nombre_servicio_educativo = models.CharField(max_length=255)
    numero_ec_asignado = models.IntegerField()
    meses_servicio = models.IntegerField()
    monto_apoyo_mensual = models.DecimalField(max_digits=10, decimal_places=2, )
    presupuesto_total_periodo = models.DecimalField(max_digits=15, decimal_places=2, )

    def calcular_presupuesto_total(self):
        """
        Calcula el presupuesto total en función del número de EC, 
        los meses del servicio y el monto mensual.
        """
        return self.numero_ec_asignado * self.meses_servicio * self.monto_apoyo_mensual

    def save(self, *args, **kwargs):
        """
        Antes de guardar, asegura que el presupuesto total se calcule automáticamente.
        """
        self.presupuesto_total_periodo = self.calcular_presupuesto_total()
        super(ApoyoGestion, self).save(*args, **kwargs)
    class Meta:
        db_table = "apoyo_gestion"
        
    def __str__(self):
        return f"{self.nombre_servicio_educativo} - EC: {self.numero_ec_asignado}"

class ServicioEducativo(models.Model):
    apoyo_gestion = models.ForeignKey(ApoyoGestion, on_delete=models.CASCADE, null=True, blank=True) #relacion
    comunidad_servicio = models.ForeignKey(Comunidad, on_delete=models.CASCADE, null=True, blank=True) #relacion
    clave_estado = models.CharField(max_length=255)
    nombre_estado = models.CharField(max_length=255, default="Estado")
    clave_region = models.CharField(max_length=255)
    nombre_region = models.CharField(max_length=255, default="Región")
    clave_microregion = models.CharField(max_length=255, default="Región")
    nombre_microregion = models.CharField(max_length=255)
    clave_comunidad = models.CharField(max_length=255)
    nombre_comunidad = models.CharField(max_length=255, default="Nombre genérico")
    rol_vacante = models.CharField(
        max_length=10,
        choices=[  # Lista de roles
            ("EC", "Educador Comunitario"),
            ("ECA", "Educador Comunitario de Acompañamiento Microrregional"),
            ("ECAR", "Educador Comunitario de Acompañamiento Regional"),
        ],
        default="EC",
    )
    tipo_servicio = models.CharField(
        max_length=255,
        choices=[
            ('Sin asignar', 'Sin asignar'),
            ('Inicial', 'Inicial'),
            ('Preescolar', 'Preescolar'),
            ('Primaria', 'Primaria'),
            ('Secundaria', 'Secundaria'),
            ('Postsecundaria', 'Postsecundaria')
        ], default='Sin asignar'
    )
    clave_centro_trabajo = models.CharField(max_length=100, null=True, blank=True)
    contexto = models.CharField(
        max_length=255,
        choices=[
            ('Sin asignar', 'Sin asignar'),
            ('Rural', 'Rural'),
            ('Urbano', 'Urbano'),
            ('Indígena', 'Indígena'),
            ('Mestizo', 'Mestizo'),
            ('Migrante', 'Migrante'),
            ('Circense', 'Circense'),
            ('Grupos Vulnerables', 'Grupos Vulnerables'),
            ('Excluidos del Sistema Regular', 'Excluidos del Sistema Regular'),
        ], default='Sin asignar'
    )

    nivel_educativo = models.CharField(
        max_length=255,
        choices=[('APEC', 'APEC'), ('APEC-INI', 'APEC-INI')]
    )
    
    contexto = models.CharField(
        max_length=255,
        choices=[
            ('Sin asignar', 'Sin asignar'),
            ('Indígena', 'Indígena'),
            ('Mestizo', 'Mestizo'),
            ('Migrante', 'Migrante'),
            ('Circense', 'Circense'),
            ('Grupos Vulnerables', 'Grupos Vulnerables'),
            ('Excluidos del Sistema Regular', 'Excluidos del Sistema Regular')
        ], default='Sin asignar'
    )
    periodo_servicio = models.CharField(
        max_length=255,
        choices=[
            ('sin asignar', 'sin asignar'),
            ('2024-2025', '2024-2025'),
            ('2025-2026', '2025-2026')
        ], default='sin asignar'
    )
    def save(self, *args, **kwargs):
        is_new = self.pk is None  # Verifica si el objeto es nuevo
        # Calcula el total de alumnos atendidos antes de guardar
        super(ServicioEducativo, self).save(*args, **kwargs)
        if is_new:

            self.__handle_observacion()  # Llamamos al método para gestionar la observación

    def __handle_observacion(self):
        """
        Método privado para gestionar la creación de observaciones.
        """
        # Crear una observación para el servicio educativo
        Observacion.objects.create(
            servicio_educativo=self,
            fecha_creacion=timezone.now(),
        )
    class Meta:
        db_table = "servicio_educativo"
    def __str__(self):
        return f"{self.nombre_comunidad} - {self.nombre_region} ({self.clave_centro_trabajo})"
    
class Observacion(models.Model):
    servicio_educativo = models.ForeignKey(
        ServicioEducativo, on_delete=models.CASCADE, null=True, blank=True
    )  # Relación con el servicio educativo
    fecha_creacion = models.DateField(null=True, blank=True)  # creacion del servicio
    fecha = models.DateField(null=True, blank=True)  # Fecha de la observación
    comentario = models.TextField(null=True, blank=True)  # Comentarios de la observación
    candidatos = models.ManyToManyField(
        'modulo_dot.Usuario', 
        blank=True, 
        related_name="observaciones"
    )  # Relación con candidatos sugeridos
    class Meta:
        db_table = "observacion"

    def __str__(self):
        return f"Observación del servicio educativo: {self.servicio_educativo.clave_centro_trabajo}"
