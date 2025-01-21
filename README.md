# Proyecto Django - Guía de Instalación y Configuración

Este proyecto está basado en Django y se recomienda usar un entorno virtual para gestionar las dependencias de manera aislada y evitar conflictos con otras bibliotecas o proyectos.

## Requisitos

Antes de comenzar, asegúrate de tener lo siguiente instalado:

- **Python 3.6+**: Puedes descargarlo desde [python.org](https://www.python.org/downloads/).
- **Git**: Para clonar el repositorio. Si no lo tienes, descárgalo desde [git-scm.com](https://git-scm.com/downloads).

## Recomendación Adicional

Es altamente recomendable usar un **entorno virtual** para gestionar las dependencias de Python. Un entorno virtual crea un espacio aislado donde puedes instalar las dependencias necesarias para este proyecto sin afectar a otras aplicaciones en tu sistema.

## Pasos para Configurar el Proyecto

Sigue estos pasos para configurar el proyecto en tu máquina local.

### 1. Clonar el Repositorio

Clona este repositorio en tu máquina local utilizando Git. Abre la terminal o línea de comandos y ejecuta:

```bash
git clone https://github.com/tu-usuario/tu-repositorio.git
cd tu-repositorio

2. Crear y Activar un Entorno Virtual
En Linux/macOS:

Para crear un entorno virtual, ejecuta el siguiente comando:

python3 -m venv env
source env/bin/activate

En Windows:

Para crear el entorno virtual en Windows, ejecuta:

python -m venv env
.\env\Scripts\activate

Cuando el entorno virtual esté activado, verás el nombre del entorno entre paréntesis en la terminal, por ejemplo: (env).
3. Instalar las Dependencias

Con el entorno virtual activado, instala las dependencias necesarias utilizando pip. Esto descargará e instalará los paquetes listados en el archivo requirements.txt:

pip install -r requirements.txt

Este archivo generalmente incluye las dependencias principales del proyecto, como Django y otras librerías necesarias.
4. Realizar Migraciones de la Base de Datos

Django requiere crear las tablas en la base de datos antes de poder usar la aplicación. Para hacerlo, ejecuta las migraciones necesarias con el siguiente comando:

python manage.py migrate

Este comando creará las tablas necesarias en la base de datos según las definiciones de los modelos de Django.
5. Ejecutar el Servidor de Desarrollo

Una vez que hayas completado los pasos anteriores, puedes iniciar el servidor de desarrollo de Django con el siguiente comando:

python manage.py runserver

Por defecto, el servidor se ejecutará en el puerto 8000. Accede a la aplicación desde tu navegador en la siguiente URL:

http://127.0.0.1:8000/
Notas Adicionales

    Desactivar el entorno virtual: Para desactivar el entorno virtual en cualquier momento, simplemente ejecuta el siguiente comando:

    deactivate

    Requisitos de Python: Si tienes múltiples versiones de Python instaladas, asegúrate de usar la versión correcta al crear el entorno virtual (por ejemplo, python3.8 -m venv env en lugar de python3).

    Dependencias adicionales: Si necesitas instalar nuevas dependencias para el proyecto, puedes agregarlas al archivo requirements.txt y luego ejecutar pip install -r requirements.txt nuevamente.

Contribuciones

Si deseas contribuir a este proyecto, por favor sigue estos pasos:

    Haz un fork de este repositorio.
    Crea una nueva rama (git checkout -b feature/nueva-funcionalidad).
    Realiza los cambios y haz commit (git commit -am 'Añadir nueva funcionalidad').
    Haz push a tu rama (git push origin feature/nueva-funcionalidad).
    Abre un pull request en GitHub.
