# Generated by Django 4.2.4 on 2024-12-13 00:10

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('login_app', '0008_alter_usuariorol_role'),
    ]

    operations = [
        migrations.AlterField(
            model_name='usuariorol',
            name='role',
            field=models.CharField(choices=[('CT', 'Coordinador Territorial'), ('DECB', 'Dirección de Educación Comunitaria e Inclusión Social'), ('DPE', 'Dirección de Planeación y Evaluación'), ('EC', 'Educador Comunitario'), ('ECA', 'Educador Comunitario de Acompañamiento Microrregional'), ('ECAR', 'Educador Comunitario de Acompañamiento Regional'), ('APEC', 'Asesor de Promoción y Educación Comunitaria'), ('DOT', 'Dirección de Operación Territorial'), ('ASPIRANTE', 'aspirante')], max_length=10),
        ),
    ]
