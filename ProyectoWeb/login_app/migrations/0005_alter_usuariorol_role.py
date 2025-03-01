# Generated by Django 4.2.4 on 2024-11-17 03:05

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('login_app', '0004_alter_usuariorol_role'),
    ]

    operations = [
        migrations.AlterField(
            model_name='usuariorol',
            name='role',
            field=models.CharField(choices=[('ADMIN', 'ADMIN'), ('DOT', 'Director de Operaciones y Tecnología'), ('CT', 'Coordinador Territorial'), ('EC', 'Educador Comunitario'), ('ECA', 'Educador Comunitario de Acompañamiento Microrregional'), ('ECAR', 'Educador Comunitario de Acompañamiento Regional'), ('APEC', 'Asesor de Promoción y Educación Comunitaria'), ('DEP', 'Desarrollo Educativo Profesional')], default='EC', max_length=10),
        ),
    ]
