# Generated by Django 4.2.4 on 2024-12-22 21:57

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('form_app', '0007_alter_aspirante_table'),
    ]

    operations = [
        migrations.AlterField(
            model_name='aspirante',
            name='folio',
            field=models.CharField(blank=True, max_length=150, null=True, unique=True),
        ),
    ]
