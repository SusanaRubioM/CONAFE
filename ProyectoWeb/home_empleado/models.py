from django.db import models

# Create your models here.
class EventoCalendario (models.Model):
    tipo_evento = models.CharField(max_length=50,
                                   choices=[('Inicio','Inicio'),
                                            ('Termino de ciclo','Termino de ciclo'),
                                            ('Colegiado','Colegiado')])
    fecha_inicio = models.DateField()
    fecha_termino = models.DateField()
    usuario = models.ForeignKey('modulo_dot.Usuario', on_delete=models.CASCADE)
    class Meta:
        db_table = "evento_calendario"
        
    def __str__(self):
        return f"{self.tipo_evento} - {self.usuario}"


class CapacitacionInical (models.Model):
    usuario = models.ForeignKey('modulo_dot.Usuario', on_delete=models.CASCADE)
    contexto = models.CharField(max_length=255)
    tipo_servicio = models.CharField(max_length=255)
    actividad = models.CharField(max_length=255)
    fecha_inicio = models.DateField()
    horas_cubiertas = models.IntegerField()

    class Meta:
        db_table = "capacitacion_inicial"

    def __str__(self):
        return f"{self.usuario} - {self.contexto}"
    

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

    