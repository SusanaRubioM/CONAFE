# Generated by Django 4.2.4 on 2024-12-01 20:29

from django.db import migrations, models
import django.db.models.deletion
import form_app.models


class Migration(migrations.Migration):

    dependencies = [
        ('form_app', '0005_aspirante_rol'),
    ]

    operations = [
        migrations.CreateModel(
            name='Residencia',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('codigo_postal', models.CharField(max_length=10)),
                ('estado', models.CharField(max_length=100)),
                ('municipio', models.CharField(max_length=100)),
                ('localidad', models.CharField(max_length=100)),
                ('colonia', models.CharField(max_length=100)),
                ('aspirante', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, related_name='residencias', to='form_app.aspirante')),
            ],
            options={
                'db_table': 'residencia',
            },
        ),
        migrations.CreateModel(
            name='Participacion',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('estado_participacion', models.CharField(max_length=100)),
                ('ciclo_escolar', models.CharField(max_length=50)),
                ('aspirante', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, related_name='participaciones', to='form_app.aspirante')),
            ],
            options={
                'db_table': 'participacion',
            },
        ),
        migrations.CreateModel(
            name='InformacionAdicional',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('habla_lengua_indigena', models.BooleanField(default=False)),
                ('talla_playera', models.CharField(max_length=5)),
                ('talla_pantalon', models.CharField(max_length=5)),
                ('talla_calzado', models.PositiveIntegerField()),
                ('banco', models.CharField(max_length=150)),
                ('cuenta_bancaria', models.CharField(max_length=20)),
                ('aspirante', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, related_name='informaciones_adicionales', to='form_app.aspirante')),
            ],
            options={
                'db_table': 'informacion_adicional',
            },
        ),
        migrations.CreateModel(
            name='Documentos',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('identificacion_oficial', models.FileField(upload_to='documentos_identificacion/', validators=[form_app.models.validate_file_size])),
                ('fotografia', models.ImageField(upload_to='fotografias_aspirantes/')),
                ('comprobante_domicilio', models.FileField(upload_to='documentos_domicilio/', validators=[form_app.models.validate_file_size])),
                ('aspirante', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, related_name='documentos', to='form_app.aspirante')),
            ],
            options={
                'db_table': 'documentos',
            },
        ),
    ]