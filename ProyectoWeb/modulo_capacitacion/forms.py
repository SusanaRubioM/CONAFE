from django import forms
from .models import CapacitacionInicial
import datetime

class CapacitacionForm(forms.ModelForm):
    class Meta:
        model = CapacitacionInicial
        fields = '__all__'
        widgets = {
            'fecha': forms.DateInput(attrs={'type': 'date'}),
            'contexto': forms.Textarea(attrs={'rows': 4, 'cols': 50}),
        }

    # Campos del formulario
    cv_region = forms.CharField(
        max_length=50,
        label="Región",
        widget=forms.TextInput(attrs={'placeholder': 'Ingrese la región'})
    )
    nombre_ecar = forms.CharField(
        max_length=100,
        label="Nombre del ECAR",
        widget=forms.TextInput(attrs={'placeholder': 'Nombre del ECAR'})
    )
    cv_microrregion = forms.CharField(
        max_length=50,
        label="Microrregión",
        widget=forms.TextInput(attrs={'placeholder': 'Microrregión'})
    )
    nombre_eca = forms.CharField(
        max_length=100,
        label="Nombre del ECA",
        widget=forms.TextInput(attrs={'placeholder': 'Nombre del ECA'})
    )
    cv_comunidad = forms.CharField(
        max_length=50,
        label="Comunidad",
        widget=forms.TextInput(attrs={'placeholder': 'Comunidad'})
    )
    id_ec = forms.CharField(
        max_length=20,
        label="ID del EC",
        widget=forms.TextInput(attrs={'placeholder': 'ID del EC'})
    )
    nombre_ec = forms.CharField(
        max_length=100,
        label="Nombre del EC",
        widget=forms.TextInput(attrs={'placeholder': 'Nombre del EC'})
    )
    ciclo_asignado = forms.CharField(
        max_length=50,
        label="Ciclo Asignado",
        widget=forms.TextInput(attrs={'placeholder': 'Ciclo Asignado'})
    )
    contexto = forms.CharField(
        label="Contexto",
        widget=forms.Textarea(attrs={'placeholder': 'Describa el contexto de la capacitación', 'rows': 4, 'cols': 50})
    )
    tipo_servicio = forms.CharField(
        max_length=50,
        label="Tipo de Servicio",
        widget=forms.TextInput(attrs={'placeholder': 'Tipo de Servicio'})
    )
    actividad = forms.CharField(
        max_length=100,
        label="Actividad",
        widget=forms.TextInput(attrs={'placeholder': 'Actividad realizada'})
    )
    fecha = forms.DateField(
        label="Fecha",
        widget=forms.DateInput(attrs={'type': 'date'}),
    )
    horas_cubiertas = forms.IntegerField(
        label="Horas Cubiertas",
        initial=0,
        widget=forms.NumberInput(attrs={'placeholder': 'Horas cubiertas'})
    )

    # Validaciones
    def clean_horas_cubiertas(self):
        horas = self.cleaned_data['horas_cubiertas']
        if horas < 0:
            raise forms.ValidationError("Las horas cubiertas no pueden ser negativas.")
        return horas

    def clean_fecha(self):
        fecha = self.cleaned_data['fecha']
        if fecha > datetime.date.today():
            raise forms.ValidationError("La fecha no puede ser en el futuro.")
        return fecha
