# Generated by Django 4.2.4 on 2024-12-13 00:14

from django.conf import settings
from django.db import migrations, models
import django.db.models.deletion


class Migration(migrations.Migration):

    dependencies = [
        migrations.swappable_dependency(settings.AUTH_USER_MODEL),
        ('modulo_dot', '0010_usuario_rol_delete_roles'),
    ]

    operations = [
        migrations.AlterField(
            model_name='usuario',
            name='usuario_rol',
            field=models.OneToOneField(blank=True, null=True, on_delete=django.db.models.deletion.CASCADE, to=settings.AUTH_USER_MODEL),
        ),
    ]
