from django import forms
from .models import CapacitacionInicial

class CapacitacionForm(forms.ModelForm):
    class Meta:
        model = CapacitacionInicial
        fields = '__all__'
        widgets = {
            'fecha': forms.DateInput(attrs={'type': 'date'}),
        }
