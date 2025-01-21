from django.db import models
from modulo_dot.models import Usuario
from modulo_apec.models import Comunidad

class Reporte(models.Model):
    periodo = models.CharField(max_length=50)
    estado = models.CharField(max_length=50, default="pendiente")
    categoria = models.CharField(max_length=50, choices=[('capacitación', 'Capacitación'), 
                                                         ('equipamiento', 'Equipamiento'), 
                                                         ('seguimiento', 'Seguimiento'),
                                                          ('sin_asignar', 'Sin asignar')],
                                                         default='sin_asignar')
    reporte = models.FileField(upload_to='reporte_pdfs/')
    usuario = models.ForeignKey(Usuario, on_delete=models.CASCADE)

    def __str__(self):
        return f"Periodo {self.periodo}"

    class Meta:
        db_table = "reportes"



class ReportesAcomp(models.Model):
    reporte = models.FileField(upload_to='reporte_acomp_pdfs/')
    fecha = models.DateField()
    figuraEducativa = models.CharField(max_length=120)
    Usuario = models.ForeignKey(Usuario, on_delete=models.CASCADE)

    class Meta:
        db_table = "reportes_acomp"

class Grupo(models.Model):
    id_Grupo = models.AutoField(primary_key=True)
    id_CCT = models.ForeignKey("modulo_apec.Comunidad", on_delete=models.CASCADE)
    Grado = models.DateField()

    class Meta:
        db_table = "grupos"


class PromocionesAlumnos(models.Model):
    id_Alumno = models.AutoField(primary_key=True)
    id_Alumno = models.ForeignKey("modulo_apec.Comunidad", on_delete=models.CASCADE)
    calfFinal = models.IntegerField(null=True, blank=True)
    tipoPromocion = models.CharField(max_length=50)
    Grado = models.CharField(max_length=50)
    Nivel = models.CharField(max_length=50)
    class Meta:
        db_table = "PromocionesAlumnos"

class Alumno(models.Model):
    actaNacimiento = models.CharField(max_length=255)
    curp = models.CharField(max_length=18)
    fechaNacimiento = models.DateField()
    lugarNacimiento = models.CharField(max_length=255)
    domicilio = models.CharField(max_length=255)
    municipio = models.CharField(max_length=255)
    estado = models.CharField(max_length=255)
    nivelEducativo = models.CharField(max_length=50)
    gradoRscolar = models.CharField(max_length=50)
    certificadoEstudios = models.BooleanField()
    nombrePadre = models.CharField(max_length=255)
    ocupacionPadre = models.CharField(max_length=255)
    telefonoPadre = models.CharField(max_length=15)
    fotoVacunacion = models.ImageField(upload_to='fotos_vacunacion/', null=True, blank=True)
    state = models.CharField(max_length=50)
    nota = models.TextField(null=True, blank=True)

    def __str__(self):
        return f"Alumno {self.curp}"

    class Meta:
        db_table = "alumnos"




class Calificacion(models.Model):
    alumno = models.ForeignKey(Alumno, on_delete=models.CASCADE)
    calificacion = models.DecimalField(max_digits=5, decimal_places=2)
    observacion = models.TextField(null=True, blank=True)

    def __str__(self):
        return f"Calificación {self.calificacion} - {self.alumno}"

    class Meta:
        db_table = "calificaciones"


class Dependencias(models.Model):
    id_Dependencias = models.AutoField(primary_key=True)
    id_Dependiente = models.IntegerField()
    id_Responsable = models.IntegerField()

    def __str__(self):
        return f"Dependencia {self.id_Dependencias}"

    class Meta:
        db_table = "dependencias"


class Recibo(models.Model):
    usuario = models.ForeignKey(Usuario, on_delete=models.CASCADE)
    recibo = models.CharField(max_length=100)
    tipoRecibo = models.CharField(max_length=100)

    def __str__(self):
        return f"Recibo {self.id_recibo}"

    class Meta:
        db_table = "recibos"


class PagosFechas(models.Model):
    fecha = models.DateField()
    tipoPago = models.CharField(max_length=50)
    monto = models.DecimalField(max_digits=10, decimal_places=2)
    usuario = models.ForeignKey(Usuario, on_delete=models.CASCADE)

    def __str__(self):
        return f"PagoFecha {self.fecha} - Monto {self.monto}"

    class Meta:
        db_table = "pagos_fechas"


class RegistroMovilario(models.Model):
    Comunidad = models.ForeignKey(Comunidad, on_delete=models.CASCADE)
    nombre = models.CharField(max_length=120)
    cantidad = models.IntegerField()
    condicion = models.CharField(max_length=120)
    periodo = models.CharField(max_length=120)
    usuario = models.ForeignKey(Usuario, on_delete=models.CASCADE)

    def __str__(self):
        return f"nombre {self.nombre} - cantidad {self.cantidad}"

    class Meta:
        db_table = "registro_movilario"


class PromocionFecha(models.Model):
    promocionPDF = models.FileField(upload_to='promociones_pdfs/')

    def __str__(self):
        return f"Promoción"

    class Meta:
        db_table = "promociones_fechas"


