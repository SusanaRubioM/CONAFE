from django import forms
from modulo_dot.models import Usuario

class UsuarioForm(forms.ModelForm):
    class Meta:
        model = Usuario
        fields = ['usuario', 'contrasenia']
        widgets = {
            'contrasenia': forms.PasswordInput(),
        }
