from rest_framework import serializers
from .models import Usuario, DatosPersonales, DocumentosPersonales
from modulo_apec.models import Comunidad
from modulo_DECB.models import PaymentSchedule
from modulo_dpe.models import Calificacion
from home_empleado.models import ReporteFiguraEducativa, ActCAP
from modulo_dpe.models import ReportesAcomp, Alumno

class UsuarioSerializer(serializers.ModelSerializer):
    class Meta:
        model = Usuario
        fields = ['id', 'usuario', 'rol', 'usuario_rol', 'contrasenia']

class DatosPersonalesSerializer(serializers.ModelSerializer):
    class Meta:
        model = DatosPersonales
        fields = '__all__'

class DocumentosPersonalesSerializer(serializers.ModelSerializer):
    class Meta:
        model = DocumentosPersonales
        fields = '__all__'

class ReporteFiguraEducativaSerializer(serializers.ModelSerializer):
    class Meta:
        model = ReporteFiguraEducativa
        fields = '__all__'

class CalificacionSerializer(serializers.ModelSerializer):
    class Meta:
        model = Calificacion
        fields = '__all__'

class ActCAPSerializer(serializers.ModelSerializer):
    class Meta:
        model = ActCAP
        fields = '__all__'

class PaymentScheduleSerializer(serializers.ModelSerializer):
    class Meta:
        model = PaymentSchedule
        fields = '__all__'

class ComunidadSerializer(serializers.ModelSerializer):
    class Meta:
        model = Comunidad
        fields = '__all__'

class ReporteAcompSerializer(serializers.ModelSerializer):
    class Meta:
        model = ReportesAcomp
        fields = '__all__'

class AlumnosSerialize(serializers.ModelSerializer):
    class Meta:
        model = Alumno
        fields = '__all__'