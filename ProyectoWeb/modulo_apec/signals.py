import random
from django.db.models.signals import post_save
from django.dispatch import receiver
from .models import Comunidad, ServicioEducativo, Microrregion, Region, Estado

@receiver(post_save, sender=Comunidad)
def crear_servicio_educativo(sender, instance, created, **kwargs):
    """
    Signal que crea automáticamente un ServicioEducativo relacionado cuando se registra una nueva Comunidad.
    """
    if created:  # Solo si la comunidad es recién creada
        microrregion = instance.microrregion
        region = microrregion.region if microrregion else None
        estado = region.estado if region else None

        # Listas para valores aleatorios
        tipos_sede = ["Central", "Auxiliar", "Rural"]
        nombres_escuelas = [
            "Escuela Primaria Benito Juárez", 
            "Escuela Secundaria Técnica No. 5", 
            "Jardín de Niños Estrella",
            "Escuela Secundaria General 1", 
            "Colegio Nacional"
        ]
        niveles_escolares = ["primaria I", "primaria II", "primaria III", "secundaria", "inicial"]
        periodos_servicio = ["2024-2025", "2025-2026", "2026-2027", "sin asignar"]
        roles_vacante = ["EC", "ECA", "ECAR"]
        
        # Generar valores aleatorios para las localidades
        comunidades = ["Macuspana", "Huimanguillo", "Jonuta", "Centro", "Tenosique", "Jalpa de Méndez", "Centla"]
        nombres_comunidad = random.choice(comunidades)  # Aleatorio de la lista de comunidades

        # Valores aleatorios para otros campos
        nombre_estado = estado.nombre_estado if estado else "Estado no asignado"
        nombre_region = region.nombre_region if region else "Región no asignada"
        nombre_microrregion = microrregion.nombre_microrregion if microrregion else "Microrregión no asignada"

        # Crear ServicioEducativo con valores aleatorios
        servicio_educativo = ServicioEducativo.objects.create(
            comunidad_servicio=instance,
            clave_estado=estado.cv_estado if estado else None,
            nombre_estado=nombre_estado,
            clave_region=region.cv_region if region else None,
            nombre_region=nombre_region,
            clave_microregion=microrregion.cv_microrregion if microrregion else None,
            nombre_microregion=nombre_microrregion,
            clave_comunidad=instance.cv_comunidad,  # Igual a cv_comunidad de la Comunidad
            nombre_comunidad=nombres_comunidad,  # Comunidad aleatoria
            tipo_sede=random.choice(tipos_sede),  # Tipo de sede aleatorio
            nombre_escuela=random.choice(nombres_escuelas),  # Nombre de escuela aleatorio
            tipo_servicio=random.choice(["preescolar", "primaria", "secundaria"]),  # Tipo de servicio aleatorio
            nivel_escolar=random.choice(niveles_escolares),  # Nivel escolar aleatorio
            periodo_servicio=random.choice(periodos_servicio),  # Periodo de servicio aleatorio
            rol_vacante=random.choice(roles_vacante),  # Rol vacante aleatorio
            cantidad_educadores_activos=random.randint(1, 10),  # Número aleatorio de educadores
            cantidad_solicitudes=random.randint(0, 20),  # Número aleatorio de solicitudes
        )
        
        # Asignar la clave de centro de trabajo igual a la clave de la comunidad
        servicio_educativo.clave_centro_trabajo = instance.cv_comunidad
        servicio_educativo.save()
