from django.db.models.signals import post_save
from django.dispatch import receiver
from .models import ConveniosFiguras
from modulo_DECB.models import PaymentSchedule
from datetime import datetime
from django.utils import timezone

@receiver(post_save, sender=ConveniosFiguras)
def create_payment_schedule(sender, instance, created, **kwargs):
    """Crea un registro de pago después de que el convenio haya sido firmado y actualiza su estado."""
    try:
        if instance.firma_digital and instance.estado_convenio == 'Aprobado':
            # Diccionario que mapea el rol a un tipo de pago y monto
            role_payment_mapping = {
                'ECAR': ('ECAR', 8803.00),
                'ECA': ('ECA', 6455.00),
                'EC': ('EC', 4684.00),
            }

            # Obtener el firmante (usuario que firmó el convenio)
            firmante = instance.firmado_por  # El usuario que firma el convenio
            if not firmante:
                raise ValueError("No se puede obtener el firmante del convenio.")

            # Ajustar el tipo de pago según el tipo de convenio
            if instance.tipo_convenio == 'Inicial':
                payment_type = 'EC_INIT'  # Tipo de pago para convenio inicial
                amount = 2603.00
            elif instance.usuario and instance.usuario.usuario_rol:
                # Mapeo de roles a tipos de pago y montos
                role = instance.usuario.usuario_rol.role
                payment_type, amount = role_payment_mapping.get(role, ('continuidad', 6000.00))
            else:
                payment_type = 'continuidad'
                amount = 6000.00

            # Crear o actualizar el registro de PaymentSchedule
            payment_schedule, created = PaymentSchedule.objects.update_or_create(
                payment_date=timezone.now(),  # Usar timezone.now() en lugar de datetime.now()
                assigned_to=instance.usuario.usuario_rol,  # El usuario relacionado con el convenio
                defaults={
                    'payment_type': payment_type,
                    'amount': amount,
                    'assigned_by': firmante.usuario_rol,  # Asignar al firmante (el que firmó el convenio)
                }
            )
            
            # Después de crear o actualizar el PaymentSchedule, actualizamos su estado
            payment_schedule.update_payment_status()

    except Exception as e:
        # Manejo de errores
        print(f"Error al crear el PaymentSchedule para el convenio {instance.id}: {str(e)}")
        # Aquí podrías agregar un manejo más avanzado, como enviar un mensaje de error o registrar el error en un log.
