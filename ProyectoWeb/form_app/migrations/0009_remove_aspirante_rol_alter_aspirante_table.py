# Generated by Django 4.2.4 on 2024-12-22 23:39

from django.db import migrations


class Migration(migrations.Migration):

    dependencies = [
        ('form_app', '0008_alter_aspirante_folio'),
    ]

    operations = [
        migrations.RemoveField(
            model_name='aspirante',
            name='rol',
        ),
        migrations.AlterModelTable(
            name='aspirante',
            table='Aspirante',
        ),
    ]