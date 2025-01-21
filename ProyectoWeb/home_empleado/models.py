from django.db import models
from modulo_dot.models import Usuario, DatosPersonales, DocumentosPersonales
from login_app.models import UsuarioRol
from django.contrib.auth.hashers import make_password
# Create your models here.

class ReporteFiguraEducativa(models.Model):
    usuario = models.ForeignKey('modulo_dot.Usuario', on_delete=models.CASCADE, db_column='usuario')
    archivo_reporte = models.FileField(upload_to="reportes_figura_educativa/", db_column='archivo_reporte')
    fecha_reporte = models.DateField(db_column='fecha_reporte')
    estado_reporte = models.CharField(max_length=50,
                                      choices=[('Pendiente', 'Pendiente'),
                                               ('Aprobado', 'Aprobado'),
                                               ('Rechazado', 'Rechazado')],
                                      db_column='estado_reporte')

    class Meta:
        db_table = "reporte_figura_educativa"

    def __str__(self):
        return f"{self.usuario} - {self.estado_reporte}"


class AsignacionGrupo(models.Model):
    id_AsignacionGrupo = models.AutoField(primary_key=True, db_column='id_AsignacionGrupo')
    id_Grupo = models.ForeignKey('modulo_dpe.Grupo', on_delete=models.CASCADE, db_column='id_Grupo')
    id_Alumno = models.ForeignKey('modulo_dpe.Alumno', on_delete=models.CASCADE, db_column='id_Alumno')

    class Meta:
        db_table = "asignacion_grupo"

    def __str__(self):
        return f"Grupo {self.id_Grupo} - Alumno {self.id_Alumno}"


class AsignacionMaestro(models.Model):
    id_AsignacionMaestro = models.AutoField(primary_key=True, db_column='id_AsignacionMaestro')
    id_Grupo = models.ForeignKey('modulo_dpe.Grupo', on_delete=models.CASCADE, db_column='id_Grupo')
    id_Maestro = models.ForeignKey('modulo_dpe.Alumno', on_delete=models.CASCADE, db_column='id_Maestro')

    class Meta:
        db_table = "asignacion_maestro"

    def __str__(self):
        return f"Grupo {self.id_Grupo} - Maestro {self.id_Maestro}"


class Materia(models.Model):
    id_Materia = models.AutoField(primary_key=True, db_column='id_Materia')
    grado = models.IntegerField(blank=True, null=True, db_column='grado')
    nivel = models.CharField(max_length=45, blank=True, null=True, db_column='nivel')
    nombre = models.CharField(max_length=45, blank=True, null=True, db_column='nombre')

    class Meta:
        db_table = "materia"

    def __str__(self):
        return self.nombre


class SolicitudEducadores(models.Model):
    id_SolicitudEducadores = models.AutoField(primary_key=True, db_column='id_SolicitudEducadores')
    nombreEscuela = models.CharField(max_length=150, blank=True, null=True, db_column='nombreEscuela')
    id_CCT = models.ForeignKey('modulo_apec.Comunidad', on_delete=models.CASCADE, db_column='id_CCT')
    tipoServicio = models.CharField(max_length=100, blank=True, null=True, db_column='tipoServicio')
    periodo = models.CharField(max_length=45, blank=True, null=True, db_column='periodo')
    numEducadores = models.IntegerField(blank=True, null=True, db_column='numEducadores')
    justificacion = models.CharField(max_length=250, blank=True, null=True, db_column='justificacion')
    contexto = models.CharField(max_length=45, blank=True, null=True, db_column='contexto')
    estado = models.CharField(max_length=45, blank=True, null=True, db_column='estado')
    educadoresAsignados = models.CharField(max_length=45, blank=True, null=True, db_column='educadoresAsignados')
    id_Usuario = models.ForeignKey('modulo_dot.Usuario', on_delete=models.CASCADE, db_column='id_Usuario')

    class Meta:
        db_table = "solicitud_educadores"

    def __str__(self):
        return self.nombreEscuela


class ActCAPMovil(models.Model):
    id_ActCAP = models.AutoField(primary_key=True, db_column='id_ActCAP')
    id_Usuario = models.ForeignKey('modulo_dot.Usuario', on_delete=models.CASCADE, db_column='id_Usuario')
    NumCapacitacion = models.IntegerField(db_column='NumCapacitacion')
    TEMA = models.TextField(db_column='TEMA')
    ClaveRegion = models.TextField(db_column='ClaveRegion')
    NombreRegion = models.TextField(db_column='NombreRegion')
    FechaProgramada = models.DateField(db_column='FechaProgramada')
    Estado = models.TextField(db_column='Estado')
    Reporte = models.TextField(db_column='Reporte')

    class Meta:
        db_table = "ActCap_Movil"

    def __str__(self):
        return self.TEMA


class ActividadCalendario(models.Model):
    titulo = models.CharField(max_length=200, db_column='titulo')
    descripcion = models.TextField(db_column='descripcion')
    fecha_inicio = models.DateTimeField(db_column='fecha_inicio')
    fecha_fin = models.DateTimeField(db_column='fecha_fin')

    class Meta:
        db_table = "actividad_calendario"

    def __str__(self):
        return self.titulo


class CapacitacionInicial(models.Model):
    ciclo_asignado = models.CharField(max_length=20, db_column='ciclo_asignado')
    contexto = models.TextField(db_column='contexto')
    actividad = models.TextField(db_column='actividad')
    fecha = models.DateField(db_column='fecha')
    horas_cubiertas = models.IntegerField(db_column='horas_cubiertas')
    cat = models.CharField(max_length=50, db_column='cat')
    finalizada = models.BooleanField(default=False, db_column='finalizada')
    created_at = models.DateTimeField(auto_now_add=True, db_column='created_at')
    updated_at = models.DateTimeField(auto_now=True, db_column='updated_at')
    ec_id = models.ForeignKey('modulo_dot.Usuario', on_delete=models.CASCADE, db_column='ec_id')
    estado = models.ForeignKey('modulo_apec.Estado', on_delete=models.CASCADE, db_column='estado')

    class Meta:
        db_table = "capacitacion_inicial"

    def __str__(self):
        return f"{self.ciclo_asignado} - {self.estado}"


class CapacitacionInicialMovil(models.Model):
    ec = models.ForeignKey(CapacitacionInicial, on_delete=models.CASCADE, related_name='moviles', db_column='ec')
    eca_id = models.ForeignKey('modulo_dot.Usuario', on_delete=models.CASCADE, db_column='eca_id')
    horas_cubiertas = models.IntegerField(db_column='horas_cubiertas')

    class Meta:
        db_table = "capacitacion_inicial_movil"

    def __str__(self):
        return f"Movil - {self.ec_id} ({self.horas_cubiertas} horas)"


class ModuloCoordinadorStatusHistory(models.Model):
    old_status = models.CharField(max_length=50, db_column='old_status')
    new_status = models.CharField(max_length=50, db_column='new_status')
    aspirante_id = models.ForeignKey(
        'modulo_dot.Usuario', 
        on_delete=models.CASCADE, 
        related_name='aspirante_statushistory',
        db_column='aspirante_id'
    )
    changed_by_id = models.ForeignKey(
        'modulo_dot.Usuario', 
        on_delete=models.CASCADE, 
        related_name='changed_by_statushistory',
        db_column='changed_by_id'
    )
    timestamp = models.DateTimeField(auto_now_add=True, db_column='timestamp')

    class Meta:
        db_table = "modulo_coordinador_statushistory"

    def __str__(self):
        return f"Status change: {self.old_status} -> {self.new_status}"


class ActCAP(models.Model):
    id_usuario = models.ForeignKey('modulo_dot.Usuario', on_delete=models.CASCADE, db_column='id_usuario', null=True, blank=True)
    num_capacitacion = models.IntegerField(db_column='num_capacitacion', null=True, blank=True)
    nombre_region = models.CharField(max_length=200, default='Tabasco')
    tema = models.CharField(max_length=200, db_column='tema', null=True, blank=True)
    id_region = models.ForeignKey('modulo_apec.Region', on_delete=models.CASCADE, db_column='id_region', null=True, blank=True)
    id_microregion = models.ForeignKey('modulo_apec.Microrregion', on_delete=models.CASCADE, db_column='id_microregion', null=True, blank=True)
    id_cct = models.ForeignKey('modulo_apec.Comunidad', on_delete=models.CASCADE, db_column='id_cct', null=True, blank=True)
    fecha_programada = models.CharField(max_length=45, db_column='fecha_programada', null=True, blank=True)
    estado = models.CharField(max_length=45, db_column='estado', null=True, blank=True)
    reporte = models.BinaryField(db_column='reporte', null=True, blank=True)

    class Meta:
        db_table = "ActCAP"

    def __str__(self):
        return f"Capacitacion {self.num_capacitacion} - {self.tema}"
