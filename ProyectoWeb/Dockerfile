FROM python:3.10-slim

# Instalar las dependencias del sistema necesarias para mysqlclient y dockerize
RUN apt-get update && apt-get install -y \
    build-essential \
    pkg-config \
    libmariadb-dev \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Descargar e instalar dockerize
RUN curl -sSL https://github.com/jwilder/dockerize/releases/download/v0.6.1/dockerize-linux-amd64-v0.6.1.tar.gz | tar -xzv && mv /dockerize /usr/local/bin/

# Establecer el directorio de trabajo
WORKDIR /app

# Copiar los archivos de tu proyecto
COPY . .

# Instalar las dependencias de Python
RUN pip install --no-cache-dir \
    asgiref==3.7.2 \
    Django==4.2.4 \
    django-widget-tweaks==1.5.0 \
    django-cors-headers==4.6.0 \
    djangorestframework==3.15.2 \
    et-xmlfile==1.1.0 \
    mysqlclient==2.2.6 \
    numpy==1.26.1 \
    openpyxl==3.1.2 \
    pandas==2.1.1 \
    Pillow==10.0.1 \
    PyPDF2==3.0.1 \
    python-dateutil==2.8.2 \
    pytz==2023.3.post1 \
    reportlab==4.2.5 \
    six==1.16.0 \
    sqlparse==0.4.4 \
    tzdata==2023.3
