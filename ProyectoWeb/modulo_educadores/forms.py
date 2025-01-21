from django import forms
from modulo_DECB.models import PaymentSchedule

class ConfirmarRecepcionForm(forms.ModelForm):
    """
    Formulario para confirmar la recepción de un pago con firma.
    """
    class Meta:
        model = PaymentSchedule
        fields = ['signature']
        widgets = {
            'signature': forms.ClearableFileInput(attrs={'class': 'form-control'}),
        }
