# Generated by Django 4.2.4 on 2024-12-22 23:39

from django.db import migrations, models
import django.db.models.deletion


class Migration(migrations.Migration):

    dependencies = [
        ('modulo_dot', '0025_alter_datospersonales_aspirante'),
    ]

    operations = [
        migrations.AlterField(
            model_name='usuario',
            name='usuario',
            field=models.OneToOneField(blank=True, null=True, on_delete=django.db.models.deletion.CASCADE, related_name='usuario_relacionado', to='modulo_dot.usuario'),
        ),
    ]