from django.apps import AppConfig


class MouduloCoordinadorConfig(AppConfig):
    default_auto_field = 'django.db.models.BigAutoField'
    name = 'modulo_coordinador'

    def ready(self):
        import modulo_coordinador.signals
