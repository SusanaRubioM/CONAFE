from django import forms
from .models import VacanteAsignada
from modulo_dot.models import Usuario
from datetime import datetime

class CapacitacionInicialForm(forms.ModelForm):
    class Meta:
        model = VacanteAsignada
        fields = ['usuario_responsable', 'usuario_eca', 'usuario_ec', 'ciclo_asignado', 'fecha', 'contexto', 'actividad', 'horas_cubiertas']
        widgets = {
            'usuario_responsable': forms.Select(attrs={'class': 'form-control', 'placeholder': 'Seleccione el ECAR'}),
            'usuario_eca': forms.Select(attrs={'class': 'form-control', 'placeholder': 'Seleccione el ECA'}),
            'usuario_ec': forms.Select(attrs={'class': 'form-control', 'placeholder': 'Seleccione el EC'}),
            'ciclo_asignado': forms.TextInput(attrs={'class': 'form-control', 'placeholder': 'Ej: 2024-2025'}),
            'fecha': forms.DateInput(attrs={'class': 'form-control', 'type': 'date'}),
            'contexto': forms.Textarea(attrs={'class': 'form-control', 'rows': 4, 'placeholder': 'Describa el contexto de la capacitación'}),
            'actividad': forms.Textarea(attrs={'class': 'form-control', 'rows': 3, 'placeholder': 'Describa la actividad realizada'}),
            'horas_cubiertas': forms.NumberInput(attrs={'class': 'form-control', 'min': '0', 'max': '240'})
        }

    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        self.fields['usuario_responsable'].queryset = Usuario.objects.filter(rol='ECAR').select_related('datospersonales')
        self.fields['usuario_eca'].queryset = Usuario.objects.filter(rol='ECA').select_related('datospersonales')
        self.fields['usuario_ec'].queryset = Usuario.objects.filter(rol='EC').select_related('datospersonales')
        self.fields['usuario_responsable'].label = 'Educador Comunitario de Acompañamiento Regional'
        self.fields['usuario_eca'].label = 'Educador Comunitario Acompañante'
        self.fields['usuario_ec'].label = 'Educador Comunitario'
        self.fields['fecha'].label = 'Fecha de inicio'
        self.fields['ciclo_asignado'].label = 'Ciclo Escolar Asignado'
        self.fields['horas_cubiertas'].label = 'Horas por Cubrir'

    def clean_fecha(self):
        fecha = self.cleaned_data.get('fecha')
        if fecha and fecha > datetime.now().date():
            raise forms.ValidationError("La fecha no puede ser futura.")
        return fecha

    def clean_horas_cubiertas(self):
        horas = self.cleaned_data.get('horas_cubiertas')
        if horas and horas > 240:
            raise forms.ValidationError("Las horas cubiertas no pueden exceder 240.")
        return horas
