from django import forms
from modulo_dot.models import Usuario
from modulo_apec.models import Observacion
class UsuarioForm(forms.ModelForm):
    class Meta:
        model = Usuario
        fields = ['usuario', 'contrasenia']
        widgets = {
            'contrasenia': forms.PasswordInput(),
        }

class ObservacionForm(forms.ModelForm):
    class Meta:
        model = Observacion
        fields = ['comentario']