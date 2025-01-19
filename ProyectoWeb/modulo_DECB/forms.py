from django import forms
from .models import PaymentSchedule
from login_app.models import UsuarioRol
from .models import CalendarEvent

class CalendarEventForm(forms.ModelForm):
    class Meta:
        model = CalendarEvent
        fields = ['event_type', 'date', 'description']
        widgets = {
            'date': forms.DateInput(attrs={'type': 'date', 'class': 'form-control'}),
        }


class PaymentAssignmentForm(forms.ModelForm):
    class Meta:
        model = PaymentSchedule
        fields = ['payment_date', 'payment_type', 'amount', 'assigned_to']
        widgets = {
            'payment_date': forms.DateInput(attrs={'type': 'date', 'class': 'form-control'}),
            'payment_type': forms.Select(attrs={'class': 'form-select'}),
            'amount': forms.NumberInput(attrs={'class': 'form-control'}),
            'assigned_to': forms.Select(attrs={'class': 'form-select'}),
        }

    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        # Filtramos los usuarios según roles específicos
        # Usamos 'usuario' en lugar de 'user' ya que ese es el campo que existe en UsuarioRol
        self.fields['assigned_to'].queryset = UsuarioRol.objects.filter(role__in=['APEC', 'EC', 'ECA', 'ECAR']).values_list('usuario', flat=True)


class PaymentScheduleForm(forms.ModelForm):
    class Meta:
        model = PaymentSchedule
        fields = ['payment_date', 'payment_type']
        labels = {
            'payment_date': 'Fecha de Pago (DD/MM/AAAA)',
            'payment_type': 'Tipo de Pago',
        }
    
    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        # Añadimos atributos de clase y placeholder para los campos
        self.fields['payment_date'].widget.attrs.update({
            'class': 'form-control', 
            'placeholder': 'DD/MM/AAAA'
        })
        self.fields['payment_type'].widget.attrs.update({
            'class': 'form-select'
        })

    def clean_payment_date(self):
        from datetime import datetime
        payment_date = self.cleaned_data['payment_date']
        # Validamos que la fecha esté en el formato correcto
        try:
            datetime.strptime(payment_date.strftime('%d/%m/%Y'), '%d/%m/%Y')
        except ValueError:
            raise forms.ValidationError('La fecha debe estar en el formato DD/MM/AAAA.')
        return payment_date
