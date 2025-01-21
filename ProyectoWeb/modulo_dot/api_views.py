from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from .models import Usuario, DatosPersonales
from .serializers import UsuarioSerializer, DatosPersonalesSerializer, ReporteFiguraEducativaSerializer, CalificacionSerializer, ActCAPSerializer, PaymentScheduleSerializer, ComunidadSerializer, AlumnosSerialize
from modulo_apec.models import Comunidad
from modulo_DECB.models import PaymentSchedule
from modulo_dpe.models import Calificacion
from home_empleado.models import ReporteFiguraEducativa, ActCAP
from modulo_dpe.models import ReportesAcomp, Alumno
from .serializers import ReporteAcompSerializer
class UsuarioAPI(APIView):
    def get(self, request, pk=None):
        if pk:
            usuario = Usuario.objects.filter(pk=pk).first()
            if not usuario:
                return Response({'error': 'Usuario no encontrado'}, status=status.HTTP_404_NOT_FOUND)
            serializer = UsuarioSerializer(usuario)
        else:
            usuarios = Usuario.objects.all()
            serializer = UsuarioSerializer(usuarios, many=True)
        return Response(serializer.data, status=status.HTTP_200_OK)

    def post(self, request):
        serializer = UsuarioSerializer(data=request.data)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

    def put(self, request, pk):
        usuario = Usuario.objects.filter(pk=pk).first()
        if not usuario:
            return Response({'error': 'Usuario no encontrado'}, status=status.HTTP_404_NOT_FOUND)
        serializer = UsuarioSerializer(usuario, data=request.data)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data, status=status.HTTP_200_OK)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

    def delete(self, request, pk):
        usuario = Usuario.objects.filter(pk=pk).first()
        if not usuario:
            return Response({'error': 'Usuario no encontrado'}, status=status.HTTP_404_NOT_FOUND)
        usuario.delete()
        return Response({'message': 'Usuario eliminado correctamente'}, status=status.HTTP_200_OK)


class DatosPersonalesAPI(APIView):
    def get(self, request, pk=None):
        if pk:
            datos_personales = DatosPersonales.objects.filter(pk=pk).first()
            if not datos_personales:
                return Response({'error': 'Datos personales no encontrados'}, status=status.HTTP_404_NOT_FOUND)
            serializer = DatosPersonalesSerializer(datos_personales)
        else:
            datos_personales = DatosPersonales.objects.all()
            serializer = DatosPersonalesSerializer(datos_personales, many=True)
        return Response(serializer.data, status=status.HTTP_200_OK)

    def post(self, request):
        serializer = DatosPersonalesSerializer(data=request.data)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

    def put(self, request, pk):
        datos_personales = DatosPersonales.objects.filter(pk=pk).first()
        if not datos_personales:
            return Response({'error': 'Datos personales no encontrados'}, status=status.HTTP_404_NOT_FOUND)
        serializer = DatosPersonalesSerializer(datos_personales, data=request.data)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data, status=status.HTTP_200_OK)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

    def delete(self, request, pk):
        datos_personales = DatosPersonales.objects.filter(pk=pk).first()
        if not datos_personales:
            return Response({'error': 'Datos personales no encontrados'}, status=status.HTTP_404_NOT_FOUND)
        datos_personales.delete()
        return Response({'message': 'Datos personales eliminados correctamente'}, status=status.HTTP_200_OK)

# ReporteFiguraEducativaAPI
class ReporteFiguraEducativaAPI(APIView):
    def get(self, request, pk=None):
        if pk:
            reporte = ReporteFiguraEducativa.objects.filter(pk=pk).first()
            if not reporte:
                return Response({'error': 'Reporte no encontrado'}, status=status.HTTP_404_NOT_FOUND)
            serializer = ReporteFiguraEducativaSerializer(reporte)
        else:
            reportes = ReporteFiguraEducativa.objects.all()
            serializer = ReporteFiguraEducativaSerializer(reportes, many=True)
        return Response(serializer.data, status=status.HTTP_200_OK)

    def post(self, request):
        serializer = ReporteFiguraEducativaSerializer(data=request.data)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

    def put(self, request, pk):
        reporte = ReporteFiguraEducativa.objects.filter(pk=pk).first()
        if not reporte:
            return Response({'error': 'Reporte no encontrado'}, status=status.HTTP_404_NOT_FOUND)
        serializer = ReporteFiguraEducativaSerializer(reporte, data=request.data)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data, status=status.HTTP_200_OK)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

    def delete(self, request, pk):
        reporte = ReporteFiguraEducativa.objects.filter(pk=pk).first()
        if not reporte:
            return Response({'error': 'Reporte no encontrado'}, status=status.HTTP_404_NOT_FOUND)
        reporte.delete()
        return Response({'message': 'Reporte eliminado correctamente'}, status=status.HTTP_200_OK)

# CalificacionAPI
class CalificacionAPI(APIView):
    def get(self, request, pk=None):
        if pk:
            calificacion = Calificacion.objects.filter(pk=pk).first()
            if not calificacion:
                return Response({'error': 'Calificación no encontrada'}, status=status.HTTP_404_NOT_FOUND)
            serializer = CalificacionSerializer(calificacion)
        else:
            calificaciones = Calificacion.objects.all()
            serializer = CalificacionSerializer(calificaciones, many=True)
        return Response(serializer.data, status=status.HTTP_200_OK)

    def post(self, request):
        serializer = CalificacionSerializer(data=request.data)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

    def put(self, request, pk):
        calificacion = Calificacion.objects.filter(pk=pk).first()
        if not calificacion:
            return Response({'error': 'Calificación no encontrada'}, status=status.HTTP_404_NOT_FOUND)
        serializer = CalificacionSerializer(calificacion, data=request.data)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data, status=status.HTTP_200_OK)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

    def delete(self, request, pk):
        calificacion = Calificacion.objects.filter(pk=pk).first()
        if not calificacion:
            return Response({'error': 'Calificación no encontrada'}, status=status.HTTP_404_NOT_FOUND)
        calificacion.delete()
        return Response({'message': 'Calificación eliminada correctamente'}, status=status.HTTP_200_OK)

# ActCAPAPI
class ActCAPAPI(APIView):
    def get(self, request, pk=None):
        if pk:
            actcap = ActCAP.objects.filter(pk=pk).first()
            if not actcap:
                return Response({'error': 'ActCAP no encontrado'}, status=status.HTTP_404_NOT_FOUND)
            serializer = ActCAPSerializer(actcap)
        else:
            actcaps = ActCAP.objects.all()
            serializer = ActCAPSerializer(actcaps, many=True)
        return Response(serializer.data, status=status.HTTP_200_OK)

    def post(self, request):
        serializer = ActCAPSerializer(data=request.data)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

    def put(self, request, pk):
        actcap = ActCAP.objects.filter(pk=pk).first()
        if not actcap:
            return Response({'error': 'ActCAP no encontrado'}, status=status.HTTP_404_NOT_FOUND)
        serializer = ActCAPSerializer(actcap, data=request.data)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data, status=status.HTTP_200_OK)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

    def delete(self, request, pk):
        actcap = ActCAP.objects.filter(pk=pk).first()
        if not actcap:
            return Response({'error': 'ActCAP no encontrado'}, status=status.HTTP_404_NOT_FOUND)
        actcap.delete()
        return Response({'message': 'ActCAP eliminado correctamente'}, status=status.HTTP_200_OK)

# PaymentScheduleAPI
class PaymentScheduleAPI(APIView):
    def get(self, request, pk=None):
        if pk:
            payment = PaymentSchedule.objects.filter(pk=pk).first()
            if not payment:
                return Response({'error': 'Pago no encontrado'}, status=status.HTTP_404_NOT_FOUND)
            serializer = PaymentScheduleSerializer(payment)
        else:
            payments = PaymentSchedule.objects.all()
            serializer = PaymentScheduleSerializer(payments, many=True)
        return Response(serializer.data, status=status.HTTP_200_OK)

    def post(self, request):
        serializer = PaymentScheduleSerializer(data=request.data)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

    def put(self, request, pk):
        payment = PaymentSchedule.objects.filter(pk=pk).first()
        if not payment:
            return Response({'error': 'Pago no encontrado'}, status=status.HTTP_404_NOT_FOUND)
        serializer = PaymentScheduleSerializer(payment, data=request.data)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data, status=status.HTTP_200_OK)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

    def delete(self, request, pk):
        payment = PaymentSchedule.objects.filter(pk=pk).first()
        if not payment:
            return Response({'error': 'Pago no encontrado'}, status=status.HTTP_404_NOT_FOUND)
        payment.delete()
        return Response({'message': 'Pago eliminado correctamente'}, status=status.HTTP_200_OK)

# ComunidadAPI
class ComunidadAPI(APIView):
    def get(self, request, pk=None):
        if pk:
            comunidad = Comunidad.objects.filter(pk=pk).first()
            if not comunidad:
                return Response({'error': 'Comunidad no encontrada'}, status=status.HTTP_404_NOT_FOUND)
            serializer = ComunidadSerializer(comunidad)
        else:
            comunidades = Comunidad.objects.all()
            serializer = ComunidadSerializer(comunidades, many=True)
        return Response(serializer.data, status=status.HTTP_200_OK)

    def post(self, request):
        serializer = ComunidadSerializer(data=request.data)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

    def put(self, request, pk):
        comunidad = Comunidad.objects.filter(pk=pk).first()
        if not comunidad:
            return Response({'error': 'Comunidad no encontrada'}, status=status.HTTP_404_NOT_FOUND)
        serializer = ComunidadSerializer(comunidad, data=request.data)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data, status=status.HTTP_200_OK)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

    def delete(self, request, pk):
        comunidad = Comunidad.objects.filter(pk=pk).first()
        if not comunidad:
            return Response({'error': 'Comunidad no encontrada'}, status=status.HTTP_404_NOT_FOUND)
        comunidad.delete()
        return Response({'message': 'Comunidad eliminada correctamente'}, status=status.HTTP_200_OK)

class ReporteAcompAPI(APIView):
    def get(self, request, pk=None):
        if pk:
            reporte_acomp = ReportesAcomp.objects.filter(pk=pk).first()
            if not reporte_acomp:
                return Response({'error': 'Reporte no encontrado'}, status=status.HTTP_404_NOT_FOUND)
            serializer = ReporteAcompSerializer(reporte_acomp)
        else:
            reportes_acomp = ReportesAcomp.objects.all()
            serializer = ReporteAcompSerializer(reportes_acomp, many=True)
        return Response(serializer.data, status=status.HTTP_200_OK)

    def post(self, request):
        serializer = ReporteAcompSerializer(data=request.data)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

    def put(self, request, pk):
        reporte_acomp = ReportesAcomp.objects.filter(pk=pk).first()
        if not reporte_acomp:
            return Response({'error': 'Reporte no encontrado'}, status=status.HTTP_404_NOT_FOUND)
        serializer = ReporteAcompSerializer(reporte_acomp, data=request.data)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data, status=status.HTTP_200_OK)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

    def delete(self, request, pk):
        reporte_acomp = ReportesAcomp.objects.filter(pk=pk).first()
        if not reporte_acomp:
            return Response({'error': 'Reporte no encontrado'}, status=status.HTTP_404_NOT_FOUND)
        reporte_acomp.delete()
        return Response({'message': 'Reporte eliminado correctamente'}, status=status.HTTP_200_OK)
    


class AlumnoAPI(APIView):
    
    # GET: Obtiene todos los alumnos o uno específico por pk
    def get(self, request, pk=None):
        if pk:
            alumno = Alumno.objects.filter(pk=pk).first()
            if not alumno:
                return Response({'error': 'Alumno no encontrado'}, status=status.HTTP_404_NOT_FOUND)
            serializer = AlumnosSerialize(alumno)
        else:
            alumnos = Alumno.objects.all()
            serializer = AlumnosSerialize(alumnos, many=True)
        
        return Response(serializer.data, status=status.HTTP_200_OK)

    # POST: Crea un nuevo alumno
    def post(self, request):
        serializer = AlumnosSerialize(data=request.data)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

    # PUT: Actualiza los datos de un alumno existente
    def put(self, request, pk):
        alumno = Alumno.objects.filter(pk=pk).first()
        if not alumno:
            return Response({'error': 'Alumno no encontrado'}, status=status.HTTP_404_NOT_FOUND)
        serializer = AlumnosSerialize(alumno, data=request.data)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data, status=status.HTTP_200_OK)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

    # DELETE: Elimina un alumno por su pk
    def delete(self, request, pk):
        alumno = Alumno.objects.filter(pk=pk).first()
        if not alumno:
            return Response({'error': 'Alumno no encontrado'}, status=status.HTTP_404_NOT_FOUND)
        alumno.delete()
        return Response({'message': 'Alumno eliminado correctamente'}, status=status.HTTP_200_OK)