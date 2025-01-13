from django import forms
from .models import CapacitacionInicial
from modulo_dot.models import Usuario
from datetime import datetime

class CapacitacionInicialForm(forms.ModelForm):
    class Meta:
        model = CapacitacionInicial
        fields = ['ecar', 'ec', 'ciclo_asignado', 'fecha', 'contexto', 'actividad', 'horas_cubiertas']
        widgets = {
            'ecar': forms.Select(attrs={'class': 'form-control', 'placeholder': 'Seleccione el ECAR'}),
            'ec': forms.Select(attrs={'class': 'form-control', 'placeholder': 'Seleccione el EC'}),
            'ciclo_asignado': forms.TextInput(attrs={'class': 'form-control', 'placeholder': 'Ej: 2024-2025'}),
            'fecha': forms.DateInput(attrs={'class': 'form-control', 'type': 'date'}),
            'contexto': forms.Textarea(attrs={'class': 'form-control', 'rows': 4, 'placeholder': 'Describa el contexto de la capacitación'}),
            'actividad': forms.Textarea(attrs={'class': 'form-control', 'rows': 3, 'placeholder': 'Describa la actividad realizada'}),
            'horas_cubiertas': forms.NumberInput(attrs={'class': 'form-control', 'min': '0', 'max': '240'})
        }

    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        self.fields['ecar'].queryset = Usuario.objects.filter(rol='ECAR').select_related('datospersonales')
        self.fields['ec'].queryset = Usuario.objects.filter(rol='EC').select_related('datospersonales')
        self.fields['ecar'].label = 'Educador Comunitario de Acompañamiento Regional'
        self.fields['ec'].label = 'Educador Comunitario'
        self.fields['ciclo_asignado'].label = 'Ciclo Escolar Asignado'
        self.fields['horas_cubiertas'].label = 'Horas de Capacitación Cubiertas'

    def clean_fecha(self):
        fecha = self.cleaned_data.get('fecha')
        return fecha

    def clean_horas_cubiertas(self):
        horas = self.cleaned_data.get('horas_cubiertas')
        if horas and horas > 240:
            raise forms.ValidationError("Las horas cubiertas no pueden exceder 240")
        return horas
