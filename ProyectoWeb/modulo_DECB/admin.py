from django.contrib import admin
from .models import PaymentSchedule

@admin.register(PaymentSchedule)
class PaymentScheduleAdmin(admin.ModelAdmin):
    list_display = ['payment_type', 'payment_date', 'assigned_by']
    search_fields = ['payment_type', 'assigned_by__username']
    list_filter = ['payment_date', 'payment_type']