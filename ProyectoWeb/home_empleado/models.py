from django.db import models

# Create your models here.
    

class ReporteFiguraEducativa:
    usuario = models.ForeignKey('modulo_dot.Usuario', on_delete=models.CASCADE)
    archivo_reporte = models.FileField(upload_to="reportes_figura_educativa/")
    fecha_reporte = models.DateField()
    estado_reporte = models.CharField(max_length=50,
                                      choices=[('Pendiente','Pendiente'),
                                               ('Aprobado','Aprobado'),
                                               ('Rechazado','Rechazado')])
    class Meta:
        db_table = "reporte_figura_educativa"

    def __str__(self):
        return f"{self.usuario} - {self.estado_reporte}"

    

"Modelo movil"

class AlumnosMovil(models.Model):
    id_Alumno = models.AutoField(primary_key=True)
    id_Maestro = models.IntegerField(null=True, blank=True)
    actaNacimiento = models.BinaryField(null=True, blank=True)  # Archivo PDF
    curp = models.TextField(null=True, blank=True)
    fechaNacimiento = models.TextField(null=True, blank=True)
    lugarNacimiento = models.TextField(null=True, blank=True)
    domicilio = models.TextField(null=True, blank=True)
    municipio = models.TextField(null=True, blank=True)
    estado = models.TextField(null=True, blank=True)
    nivelEducativo = models.TextField(null=True, blank=True)
    gradoEscolar = models.TextField(null=True, blank=True)
    certificadoEstudios = models.BinaryField(null=True, blank=True)  # Archivo PDF
    nombrePadre = models.TextField(null=True, blank=True)
    ocupacionPadre = models.TextField(null=True, blank=True)
    telefonoPadre = models.TextField(null=True, blank=True)
    fotoVacunacion = models.BinaryField(null=True, blank=True)  # Imagen
    state = models.TextField(null=True, blank=True)
    nota = models.TextField(null=True, blank=True)
    id_Maestro = models.ForeignKey('UsuariosMovil', null=True, blank=True, on_delete=models.CASCADE)

    class Meta:
        db_table = "alumnos_movil"

    def __str__(self):
        return self.curp


class ComunidadMovil(models.Model):
    id_Comunidad = models.AutoField(primary_key=True)
    claveMicroRegion = models.TextField()
    Nombre = models.TextField()

    class Meta:
        db_table = "comunidad_movil"

    def __str__(self):
        return self.Nombre


class UsuariosMovil(models.Model):
    id_Usuario = models.AutoField(primary_key=True)
    usuario = models.TextField()
    password = models.TextField()
    rol = models.TextField()
    id_Datos = models.ForeignKey('DatosUsuariosMovil', null=True, blank=True, on_delete=models.CASCADE)

    class Meta:
        db_table = "usuarios_movil"

    def __str__(self):
        return self.usuario


class DependenciasMovil(models.Model):
    id_Dependencias = models.AutoField(primary_key=True)
    id_Dependiente = models.ForeignKey('UsuariosMovil', related_name='dependiente', on_delete=models.CASCADE)
    id_Responsable = models.ForeignKey('UsuariosMovil', related_name='responsable', on_delete=models.CASCADE)

    class Meta:
        db_table = "dependencias_movil"

    def __str__(self):
        return f"Dependencia {self.id_Dependencias}"


class DatosUsuariosMovil(models.Model):
    id_Datos = models.AutoField(primary_key=True)
    nombreCompleto = models.TextField()
    id_Comunidad = models.ForeignKey('ComunidadMovil', null=True, blank=True, on_delete=models.CASCADE)
    situacion_Educativa = models.TextField(null=True, blank=True)
    tipoServicio = models.TextField(null=True, blank=True)
    contexto = models.TextField(null=True, blank=True)
    Estado = models.BooleanField()

    class Meta:
        db_table = "datos_usuarios_movil"

    def __str__(self):
        return self.nombreCompleto


class ReportesMovil(models.Model):
    id_Reporte = models.AutoField(primary_key=True)
    periodo = models.TextField()
    estado = models.TextField()
    reporte = models.BinaryField()
    id_usuario = models.ForeignKey('UsuariosMovil', on_delete=models.CASCADE)

    class Meta:
        db_table = "reportes_movil"

    def __str__(self):
        return self.periodo


class ActividadAcompMovil(models.Model):
    id_ActividadAcomp = models.AutoField(primary_key=True)
    id_Usuario = models.ForeignKey('UsuariosMovil', on_delete=models.CASCADE)
    fecha = models.DateField()
    hora = models.TimeField()
    nombreEC = models.TextField()
    descripcion = models.TextField()
    estado = models.TextField()

    class Meta:
        db_table = "actividad_acomp_movil"

    def __str__(self):
        return self.nombreEC


class ReportesAcompMovil(models.Model):
    id_ReporteAcomp = models.AutoField(primary_key=True)
    reporte = models.BinaryField()
    id_ActividadAcomp = models.ForeignKey('ActividadAcompMovil', on_delete=models.CASCADE)
    fecha = models.DateField()
    figuraEducativa = models.TextField()
    id_Usuario = models.ForeignKey('UsuariosMovil', on_delete=models.CASCADE)

    class Meta:
        db_table = "reportes_acomp_movil"

    def __str__(self):
        return self.figuraEducativa


class AsistenciaMovil(models.Model):
    id_Asistencia = models.AutoField(primary_key=True)
    id_Profesor = models.ForeignKey('UsuariosMovil', on_delete=models.CASCADE)
    fecha = models.DateField()
    usuario = models.TextField()
    horaEntrada = models.TimeField()
    horaSalida = models.TimeField()
    Asistencia = models.BooleanField()

    class Meta:
        db_table = "asistencia_movil"

    def __str__(self):
        return f"Asistencia {self.id_Asistencia}"


class ActividadAlumnosMovil(models.Model):
    id_ActAlum = models.AutoField(primary_key=True)
    titulo = models.TextField()
    descripcion = models.TextField()
    periodo = models.TextField()
    materia = models.TextField()
    estado = models.TextField()

    class Meta:
        db_table = "actividad_alumnos_movil"

    def __str__(self):
        return self.titulo


class CalificacionesMovil(models.Model):
    id_Calf = models.AutoField(primary_key=True)
    id_ActAlum = models.ForeignKey('ActividadAlumnosMovil', on_delete=models.CASCADE)
    id_Alumno = models.ForeignKey('AlumnosMovil', on_delete=models.CASCADE)
    calificacion = models.IntegerField()
    observacion = models.TextField(null=True, blank=True)

    class Meta:
        db_table = "calificaciones_movil"

    def __str__(self):
        return f"Calificación {self.calificacion}"


class RegistroMoviliarioMovil(models.Model):
    id_RMoviliario = models.AutoField(primary_key=True)
    id_Comunidad = models.ForeignKey('ComunidadMovil', on_delete=models.CASCADE)
    nombre = models.TextField()
    cantidad = models.IntegerField()
    condicion = models.TextField()
    comentarios = models.TextField()
    periodo = models.TextField()
    id_Usuario = models.ForeignKey('UsuariosMovil', on_delete=models.CASCADE)

    class Meta:
        db_table = "registro_moviliario_movil"

    def __str__(self):
        return self.nombre


class ReciboMovil(models.Model):
    id_Recibo = models.AutoField(primary_key=True)
    id_Usuario = models.ForeignKey('UsuariosMovil', on_delete=models.CASCADE)
    recibo = models.BinaryField()
    tipoRecibo = models.TextField()

    class Meta:
        db_table = "recibo_movil"

    def __str__(self):
        return self.tipoRecibo


class ActCAPMovil(models.Model):
    id_ActCAP = models.AutoField(primary_key=True)
    id_Usuario = models.ForeignKey('UsuariosMovil', on_delete=models.CASCADE)
    NumCapacitacion = models.IntegerField()
    TEMA = models.TextField()
    ClaveRegion = models.TextField()
    NombreRegion = models.TextField()
    FechaProgramada = models.DateField()
    Estado = models.TextField()
    Reporte = models.TextField()

    class Meta:
        db_table = "act_cap_movil"

    def __str__(self):
        return self.TEMA


class PromocionFechasMovil(models.Model):
    id_PromoFechas = models.AutoField(primary_key=True)
    promocionPDF = models.BinaryField()
    fechas = models.TextField()

    class Meta:
        db_table = "promocion_fechas_movil"

    def __str__(self):
        return self.fechas


class PagosFechasMovil(models.Model):
    id_PagoFecha = models.AutoField(primary_key=True)
    fecha = models.DateField()
    tipoPago = models.TextField()
    monto = models.FloatField()
    id_Usuario = models.ForeignKey('UsuariosMovil', on_delete=models.CASCADE)

    class Meta:
        db_table = "pagos_fechas_movil"

    def __str__(self):
        return f"{self.tipoPago} - {self.monto}"
