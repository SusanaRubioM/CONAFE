# Generated by Django 4.2.4 on 2024-12-21 04:06

from django.conf import settings
from django.db import migrations, models
import django.db.models.deletion


class Migration(migrations.Migration):

    dependencies = [
        migrations.swappable_dependency(settings.AUTH_USER_MODEL),
        ('modulo_dot', '0019_alter_usuario_table'),
    ]

    operations = [
        migrations.AlterField(
            model_name='usuario',
            name='usuario_rol',
            field=models.OneToOneField(default=7, on_delete=django.db.models.deletion.CASCADE, to=settings.AUTH_USER_MODEL),
            preserve_default=False,
        ),
    ]
