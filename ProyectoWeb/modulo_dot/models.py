import os
from django.db import models
from django.core.validators import FileExtensionValidator
from login_app.models import UsuarioRol  # Importa el modelo UsuarioRol de login_app
from login_app.models import Statuses  # Importa el modelo Statuses
from django.contrib.auth.hashers import make_password
from login_app.models import UsuarioRol  # Lo importamos localmente dentro de save
from modulo_apec.models import ApoyoGestion  # Importa el modelo ApoyoGestion de modulo_apec
from modulo_coordinador.models import ConveniosFiguras
from modulo_apec.models import ServicioEducativo  # Importa el modelo ServicioEducativo de modulo_apec
class Usuario(models.Model):
    usuario_rol = models.OneToOneField(UsuarioRol, null=True, blank=True, on_delete=models.CASCADE)
    usuario = models.CharField(max_length=255, unique=True, null=True, blank=True)
    contrasenia = models.CharField(max_length=255, null=True, blank=True)  # Contraseña en texto plano
    rol = models.CharField(
        max_length=10,
        choices=[  # Lista de roles
            ("CT", "Coordinador Territorial"),
            ("DECB", "Dirección de Educación Comunitaria e Inclusión Social"),
            ("DPE", "Dirección de Planeación y Evaluación"),
            ("EC", "Educador Comunitario"),
            ("ECA", "Educador Comunitario de Acompañamiento Microrregional"),
            ("ECAR", "Educador Comunitario de Acompañamiento Regional"),
            ("APEC", "Asesor de Promoción y Educación Comunitaria"),
            ("DOT", "Dirección de Operación Territorial"),
            ("ASPIRANTE", "aspirante"),
        ],
        default="ASPIRANTE",
    )

    def save(self, *args, **kwargs):
        # Validar solo si el rol no es "ASPIRANTE"
        if self.rol != "ASPIRANTE":
            if not self.usuario or not self.contrasenia:
                raise ValueError("Los campos 'usuario' y 'contrasenia' son obligatorios para roles distintos de 'ASPIRANTE'.")

        # Si el rol es "ASPIRANTE", no asignar username ni password
        if self.rol == "ASPIRANTE":
            self.usuario = None
            self.contrasenia = None
            if not self.usuario_rol:
                self.usuario_rol = UsuarioRol.objects.create(
                    username=None,
                    role=self.rol,
                    password=None,
                    is_active=False,
                )
        else:
            # Crear `usuario_rol` solo si no existe
            if not self.usuario_rol:
                self.usuario_rol = UsuarioRol.objects.create(
                    username=self.usuario,
                    role=self.rol,
                    password=make_password(self.contrasenia),
                )

        super().save(*args, **kwargs)

        # Llamamos a los métodos para gestionar el convenio, apoyo de gestión y estado
        self._handle_convenio()
        self._handle_apoyo_gestion()  
        self._handle_statuses()

    def _handle_convenio(self):
        """Gestiona la creación del objeto ConveniosFiguras basado en el estado del usuario."""
        if self.rol in ["ASPIRANTE", "EC", "ECA", "ECAR"]:
            # Comprobamos el último estado del usuario
            status = Statuses.objects.filter(usuario=self).order_by('-id').first()  # Último estado
            estado_convenio = 'Pendiente'  # Predeterminado

            if status:
                if status.status == 'suspendida':
                    estado_convenio = 'Pendiente'
                elif status.status == 'capacitacion':
                    estado_convenio = 'Aprobado'
                else:
                    estado_convenio = 'Rechazado'

            # Crear o actualizar el convenio con el estado evaluado
            convenio, created = ConveniosFiguras.objects.update_or_create(
                usuario=self,
                defaults={
                    'convenio_pdf': os.path.join('documentos', 'Convenio_figuras.pdf'),
                    'firma_digital': None,  # Firma digital puede ser añadida posteriormente
                    'estado_convenio': estado_convenio,
                    'firmado_por': None,
                },
            )

            if created:
                print(f"Convenio creado para el usuario {self.usuario} con estado {estado_convenio}")
            else:
                print(f"Convenio actualizado para el usuario {self.usuario} con estado {estado_convenio}")

    def _handle_statuses(self):
        """Gestiona la creación o actualización del estado del usuario según su rol."""
        if self.rol != "ASPIRANTE":
            # Si el rol es distinto a 'ASPIRANTE', se marca como 'activado'
            Statuses.objects.update_or_create(
                usuario=self,
                defaults={'status': 'activado'}
            )
        elif self.rol == "EC":
            # Si el rol es 'EC', se marca como 'capacitacion'
            Statuses.objects.update_or_create(
                usuario=self,
                defaults={'status': 'capacitacion'}
            )
        else:
            # Si el rol es 'ASPIRANTE' (o cualquier otro no mencionado antes), se marca como 'suspendido'
            Statuses.objects.update_or_create(
                usuario=self,
                defaults={'status': 'suspendido'}
            )

        # Asegurar que los convenios se actualicen acorde al estado
        self._handle_convenio()

    def _handle_apoyo_gestion(self):
        """Gestionar el apoyo de gestión para el rol 'EC' y crear ServicioEducativo asociado."""
        if self.rol == "EC":
            apoyo_gestion, created = ApoyoGestion.objects.update_or_create(
                usuario=self, 
                defaults={
                    'nombre_servicio_educativo': 'SERVICIO ED BASICA 22-2',  # Cambiar según corresponda
                    'numero_ec_asignado': 1,  # Ajustar según la lógica de negocio
                    'meses_servicio': 12,  # Ajustar según la lógica de negocio
                    'monto_apoyo_mensual': 6000,  # Establecer un valor predeterminado
                }
            )

            # Después de crear o actualizar el ApoyoGestion, recalculamos el presupuesto total
            if not created:
                # Si no es creado, recalculamos el presupuesto total
                apoyo_gestion.presupuesto_total_periodo = apoyo_gestion.calcular_presupuesto_total()
                apoyo_gestion.save()

    class Meta:
        db_table = "usuario"

    def __str__(self):
        return f"{self.usuario} - {self.rol}"


# Modelo de Datos Personales
class DatosPersonales(models.Model):
    nombre = models.CharField(max_length=255)
    apellidopa = models.CharField(max_length=255)
    apellidoma = models.CharField(max_length=255)
    edad = models.IntegerField()
    sexo = models.CharField(
        max_length=50,
        choices=[ 
            ("Masculino", "Masculino"),
            ("Femenino", "Femenino"),
            ("Otro", "Otro"),
        ],
    )
    correo = models.EmailField(unique=True)
    telefono = models.CharField(max_length=50)
    formacion_academica = models.CharField(max_length=255)
    curp = models.CharField(max_length=18, unique=True)
    fotografia = models.ImageField(
        upload_to="fotografias_personales/", null=True, blank=True
    )

    usuario = models.OneToOneField(Usuario, on_delete=models.CASCADE)  # Relación OneToOne con Usuario

    def save(self, *args, **kwargs):
        # Asegurarse de que no existan datos personales asociados al usuario
        #if DatosPersonales.objects.filter(usuario=self.usuario).exists():
           # raise ValueError("Este usuario ya tiene datos personales asociados.")
        super().save(*args, **kwargs)

    class Meta:
        db_table = "datos_personales"

    def __str__(self):
        return f"{self.nombre} {self.apellidopa} {self.apellidoma}"


# Modelo de Documentos Personales
class DocumentosPersonales(models.Model):
    datos_personales = models.OneToOneField(
        "DatosPersonales",  # Usamos 'DatosPersonales' como referencia
        related_name="documentos",
        on_delete=models.CASCADE,
    )
    identificacion_oficial = models.FileField(
        upload_to="documentos_identificacion/",
        validators=[FileExtensionValidator(allowed_extensions=["pdf", "jpg", "png"])],
        null=True,  # Permite que el campo sea nulo
        blank=True,  # Permite que el campo esté vacío
    )
    comprobante_domicilio = models.FileField(
        upload_to="documentos_domicilio/",
        validators=[FileExtensionValidator(allowed_extensions=["pdf", "jpg", "png"])],
        null=True,  # Permite que el campo sea nulo
        blank=True,  # Permite que el campo esté vacío
    )
    certificado_estudio = models.FileField(
        upload_to="documentos_estudio/",
        validators=[FileExtensionValidator(allowed_extensions=["pdf", "jpg", "png"])],
        null=True,  # Permite que el campo sea nulo
        blank=True,  # Permite que el campo esté vacío
    )

    class Meta:
        db_table = "documentos_personales"
        verbose_name = "Documento Personal"
        verbose_name_plural = "Documentos Personales"

    def __str__(self):
        return f"Documentos de {self.datos_personales.nombre} {self.datos_personales.apellidopa}"

"""class DatosUsuario(models.Model):
    id_Datos = models.CharField(
        max_length=10,
        primary_key=True,
        verbose_name="Clave única del municipio",
    )
    nombreCompleto = models.CharField(max_length=255, unique=True, null=True, blank=True)
    id_comunidad = models.ForeignKey(
        'modulo_apec.Comunidad', on_delete=models.CASCADE, null=True, blank=True
    )
    situacion_Educativa = models.CharField(max_length=255, null=True, blank=True)
    tipoServicio = models.CharField(max_length=255, null=True, blank=True)
    contexto = models.CharField(max_length=255, null=True, blank=True)
    Estado = models.CharField(max_length=255, null=True, blank=True)
    class Meta:
        db_table = "datos_usuario"

    def __str__(self):
        return self.nombreCompleto or "DatosUsuario sin nombre"




class UsuariosApi(models.Model):
    id_Usuario = models.CharField(
        max_length=10,
        primary_key=True,
        verbose_name="Clave única del usuario",
    )
    usuario_api = models.CharField(max_length=255, unique=True, null=True, blank=True)
    password = models.CharField(max_length=255, null=True, blank=True)  # Considera usar make_password
    rol = models.CharField(max_length=255, null=True, blank=True)
    id_Datos = models.ForeignKey(
        DatosUsuario, on_delete=models.CASCADE, null=True, blank=True
    )
    class Meta:
        db_table = "usuario_api"

    def __str__(self):
        return self.usuario_api or "Usuario sin nombre"
    """