from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from .models import Usuario
from .serializers import UsuarioSerializer

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
