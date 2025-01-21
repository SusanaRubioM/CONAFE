from django.apps import AppConfig


class ModuloApecConfig(AppConfig):
    default_auto_field = 'django.db.models.BigAutoField'
    name = 'modulo_apec'

    def ready(self):
        import modulo_apec.signals # Importar las señales
