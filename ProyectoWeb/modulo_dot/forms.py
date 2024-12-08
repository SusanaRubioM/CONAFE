from django import forms
from .models import Empleado

class EmpleadoForm(forms.ModelForm):
    class Meta:
        model = Empleado
        fields = ['nombre', 'apellidopa', 'apellidoma', 'email', 'edad', 'genero', 'salario', 'foto', 'rol', 'username', 'password']

    # Si necesitas validaciones adicionales
    username = forms.CharField(max_length=150)
    password = forms.CharField(widget=forms.PasswordInput())


