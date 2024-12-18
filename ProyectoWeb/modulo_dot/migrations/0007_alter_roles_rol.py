# Generated by Django 4.2.4 on 2024-12-12 22:22

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('modulo_dot', '0006_alter_documentospersonales_certificado_estudio_and_more'),
    ]

    operations = [
        migrations.AlterField(
            model_name='roles',
            name='rol',
            field=models.CharField(choices=[('CT', 'Coordinador Territorial'), ('CT', 'Coordinador Territorial'), ('DECB', 'Dirección de Educación Comunitaria e Inclusión Social'), ('DPE', 'Dirección de Planeación y Evaluación'), ('EC', 'Educador Comunitario'), ('ECA', 'Educador Comunitario de Acompañamiento Microrregional'), ('ECAR', 'Educador Comunitario de Acompañamiento Regional'), ('APEC', 'Asesor de Promoción y Educación Comunitaria'), ('DOT', 'Dirección de Operación Territorial')], max_length=10, unique=True),
        ),
    ]
