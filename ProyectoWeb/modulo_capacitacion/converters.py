from django.urls import register_converter

class UsuarioIDConverter:
    regex = '[0-9]+'

    def to_python(self, value):
        return int(value)

    def to_url(self, value):
        return str(value)

register_converter(UsuarioIDConverter, 'usuario_id')
