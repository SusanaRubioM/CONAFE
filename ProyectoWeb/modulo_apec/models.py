from django.db import models
from django.core.validators import MinValueValidator, RegexValidator
from django.utils import timezone

# Modelo para Estados
class Estado(models.Model):
    cv_estado = models.CharField(
        max_length=5,
        primary_key=True,
        verbose_name="Clave única del estado",
        validators=[RegexValidator(regex='^[A-Za-z0-9]+$', message="Solo se permiten letras y números.")]
    )
    nombre_estado = models.CharField(max_length=100, verbose_name="Nombre completo del estado")

    class Meta:
        db_table = "estado"

    def __str__(self):
        return self.nombre_estado


class Municipio(models.Model):
    cv_municipio = models.CharField(
        max_length=10,
        primary_key=True,
        verbose_name="Clave única del municipio",
        validators=[RegexValidator(regex='^[A-Za-z0-9]+$', message="Solo se permiten letras y números.")]
    )
    nombre_municipio = models.CharField(max_length=100, verbose_name="Nombre completo del municipio")
    estado = models.ForeignKey(Estado, on_delete=models.CASCADE, related_name="municipios", verbose_name="Estado al que pertenece", null=True, blank=True)

    class Meta:
        db_table = "municipio"

    def __str__(self):
        return self.nombre_municipio


# Modelo para Regiones
class Region(models.Model):
    cv_region = models.CharField(
        max_length=10,
        primary_key=True,
        verbose_name="Clave única de la región",
        validators=[RegexValidator(regex='^[A-Za-z0-9]+$', message="Solo se permiten letras y números.")]
    )
    nombre_region = models.CharField(max_length=100, verbose_name="Nombre completo de la región")
    estado = models.ForeignKey(Estado, on_delete=models.CASCADE, related_name="regiones", verbose_name="Estado al que pertenece", null=True, blank=True)
    municipios_region = models.CharField(max_length=255, verbose_name="Municipios que pertenecen a la región", null=True, blank=True)

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
        null=True, blank=True
    )
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
        null=True, blank=True
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
        ], 
        default='Sin asignar',
        null=True, blank=True
    )
    tipo_servicio = models.TextField(verbose_name="Tipo de servicio educativo que se ofrece", null=True, blank=True)
    usuario = models.OneToOneField('modulo_dot.Usuario', on_delete=models.CASCADE, null=True, blank=True)
    estatus = models.CharField(
        max_length=8,
        choices=[('Activo', 'Activo'), ('Inactivo', 'Inactivo')],
        verbose_name="Estado actual de la comunidad",
        null=True, blank=True
    )
    localizacion = models.FileField(
        upload_to='comunidades/', 
        verbose_name="Archivo asociado a la comunidad", 
        null=True, blank=True
    )

    class Meta:
        db_table = "comunidad"

    def __str__(self):
        return self.nombre_comunidad


class ApoyoGestion(models.Model):
    usuario = models.OneToOneField('modulo_dot.Usuario', on_delete=models.CASCADE, null=True, blank=True)
    nombre_servicio_educativo = models.CharField(max_length=255)
    numero_ec_asignado = models.IntegerField()
    meses_servicio = models.IntegerField()
    monto_apoyo_mensual = models.DecimalField(max_digits=10, decimal_places=2)
    presupuesto_total_periodo = models.DecimalField(max_digits=15, decimal_places=2)

    def calcular_presupuesto_total(self):
        return self.numero_ec_asignado * self.meses_servicio * self.monto_apoyo_mensual

    def save(self, *args, **kwargs):
        self.presupuesto_total_periodo = self.calcular_presupuesto_total()
        super(ApoyoGestion, self).save(*args, **kwargs)
    
    class Meta:
        db_table = "apoyo_gestion"
        
    def __str__(self):
        return f"{self.nombre_servicio_educativo} - EC: {self.numero_ec_asignado}"



class ServicioEducativo(models.Model):
    apoyo_gestion = models.ForeignKey(ApoyoGestion, on_delete=models.CASCADE, null=True, blank=True)
    comunidad_servicio = models.ForeignKey(Comunidad, on_delete=models.CASCADE, null=True, blank=True)
    clave_estado = models.CharField(max_length=255, null=True, blank=True)
    nombre_estado = models.CharField(max_length=255, default="Estado")
    clave_region = models.CharField(max_length=255, null=True, blank=True)
    nombre_region = models.CharField(max_length=255, default="Región")
    clave_microregion = models.CharField(max_length=255, default="Región")
    nombre_microregion = models.CharField(max_length=255)
    clave_comunidad = models.CharField(max_length=255)
    nombre_comunidad = models.CharField(max_length=255, default="Nombre genérico")
    clave_centro_trabajo = models.CharField(max_length=100, null=True, blank=True)
    nombre_escuela = models.CharField(max_length=255, null=True, blank=True)
    tipo_sede = models.CharField(max_length=255, null=True, blank=True)
    tipo_servicio = models.CharField(
        max_length=255,
        choices=[
            ("preescolar", "Preescolar"),
            ("primaria", "Primaria"),
            ("secundaria", "Secundaria")
        ], null=True, blank=True
    )
    nivel_escolar = models.CharField(
        max_length=255,
        choices=[
            ("primaria I", "Primaria I"),
            ("primaria II", "Primaria II"),
            ("primaria III", "Primaria III"),
            ("secundaria", "Secundaria"),
            ("inicial", "Inicial")
        ],
        null=True, blank=True
    )
    periodo_servicio = models.CharField(
        max_length=255,
        choices=[ 
            ('sin asignar', 'sin asignar'),
            ('2024-2025', '2024-2025'),
            ('2025-2026', '2025-2026')
        ], default='sin asignar',
        null=True, blank=True  # Hacerlo opcional
    )
    rol_vacante = models.CharField(
        max_length=10,
        choices=[  
            ("EC", "Educador Comunitario"),
            ("ECA", "Educador Comunitario de Acompañamiento Microrregional"),
            ("ECAR", "Educador Comunitario de Acompañamiento Regional"),
        ],
        null=True, blank=True  # Hacerlo opcional
    )

    # Nuevos campos
    cantidad_educadores_activos = models.IntegerField(default=0)  # Número de educadores activos
    cantidad_solicitudes = models.IntegerField(default=0)  # Número de solicitudes realizadas
    status = models.CharField(
        max_length=10,
        choices=[
            ("aprobado", "Aprobado"),
            ("rechazado", "Rechazado"),
            ("pendiente", "Pendiente")
        ],
        default="Pendiente",
        null=True, blank=True
    )

    def save(self, *args, **kwargs):
        is_new = self.pk is None
        super(ServicioEducativo, self).save(*args, **kwargs)
        if is_new:
            self.__handle_observacion()

    def __handle_observacion(self):
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
    )
    fecha_creacion = models.DateField(null=True, blank=True)
    fecha = models.DateField(null=True, blank=True)
    comentario = models.TextField(null=True, blank=True)
    candidatos = models.ManyToManyField(
        'modulo_dot.Usuario', 
        blank=True, 
        related_name="observaciones"
    )

    class Meta:
        db_table = "observacion"

    def __str__(self):
        return f"Observación del servicio educativo: {self.servicio_educativo.clave_centro_trabajo}"
    

class DatosComplementarios(models.Model):
    id_SituacionEducativa = models.AutoField(primary_key=True)
    id_Usuario = models.ForeignKey('modulo_dot.Usuario', on_delete=models.SET_NULL, null=True, blank=True, related_name='datos_complementarios')
    situacionEducativa = models.CharField(max_length=100, null=True, blank=True)
    
    # Relación con Región, Microrregión, y otros detalles geográficos
    Region = models.ForeignKey('modulo_apec.Region', on_delete=models.SET_NULL, null=True, blank=True, related_name='datos_complementarios')
    Microregion = models.ForeignKey('modulo_apec.Microrregion', on_delete=models.SET_NULL, null=True, blank=True, related_name='datos_complementarios')
    
    CCT = models.CharField(max_length=45, null=True, blank=True)
    contexto = models.CharField(max_length=80, null=True, blank=True)
    nivel = models.CharField(max_length=45, null=True, blank=True)

    class Meta:
        db_table = 'datos_complementarios'
        verbose_name = 'Dato Complementario'
        verbose_name_plural = 'Datos Complementarios'

    def __str__(self):
        return f"Datos complementarios de {self.id_Usuario} - {self.situacionEducativa}"
