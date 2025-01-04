from django import forms
from .models import Observacion

class ObservacionForm(forms.ModelForm):
    class Meta:
        model = Observacion
        fields = ['comentario']

