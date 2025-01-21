from rest_framework import serializers
from .models import Usuario, DatosPersonales, DocumentosPersonales

class UsuarioSerializer(serializers.ModelSerializer):
    class Meta:
        model = Usuario
        fields = ['id', 'usuario', 'rol', 'usuario_rol', 'contrasenia']  # Incluye solo los campos necesarios

class DatosPersonalesSerializer(serializers.ModelSerializer):
    class Meta:
        model = DatosPersonales
        fields = '__all__'

class DocumentosPersonalesSerializer(serializers.ModelSerializer):
    class Meta:
        model = DocumentosPersonales
        fields = '__all__'
