# Imagen base: Python 3.11 versión ligera
FROM python:3.11-slim

# Instala Java (necesario para PySpark)
RUN apt-get update && apt-get install -y \
    default-jdk \
    && rm -rf /var/lib/apt/lists/*

# Variables de entorno para que PySpark encuentre Java
ENV JAVA_HOME=/usr/lib/jvm/default-java
ENV PATH=$PATH:$JAVA_HOME/bin

# Carpeta de trabajo dentro del contenedor
WORKDIR /app

# Copia requirements.txt e instala dependencias
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Abre el puerto 8888 para Jupyter
EXPOSE 8888

# Comando que se ejecuta al iniciar el contenedor
CMD ["jupyter", "notebook", "--ip=0.0.0.0", "--port=8888", "--no-browser", "--allow-root", "--NotebookApp.token=''"]