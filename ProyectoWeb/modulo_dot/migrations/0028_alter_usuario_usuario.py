# Generated by Django 4.2.4 on 2024-12-22 23:49

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('modulo_dot', '0027_alter_usuario_usuario'),
    ]

    operations = [
        migrations.AlterField(
            model_name='usuario',
            name='usuario',
            field=models.CharField(blank=True, max_length=255, null=True),
        ),
    ]