# Generated by Django 4.2.4 on 2024-12-22 21:41

from django.db import migrations, models
import django.db.models.deletion


class Migration(migrations.Migration):

    dependencies = [
        ('form_app', '0006_alter_aspirante_datos_personales'),
        ('modulo_dot', '0023_alter_datospersonales_aspirante'),
    ]

    operations = [
        migrations.AlterField(
            model_name='datospersonales',
            name='aspirante',
            field=models.OneToOneField(on_delete=django.db.models.deletion.CASCADE, related_name='datos_personales_info', to='form_app.aspirante'),
        ),
    ]
