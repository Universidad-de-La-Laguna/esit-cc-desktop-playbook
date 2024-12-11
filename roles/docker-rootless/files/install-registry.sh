#!/bin/bash

systemctl start docker.service
systemctl start containerd.service
echo "ASDFASDFASFJÑKLSAFJDAÑSLKFJSAKLÑFDJ"
sleep 10


# Comprobar si el contenedor "docker-registry-proxy" ya está en ejecución
if docker ps --filter "name=docker-registry-proxy" --format "{{.Names}}" | grep -q "docker-registry-proxy"; then
  echo "El proxy local ya está en ejecución. No es necesario crear uno nuevo."
  else
  echo "Creando el proxy local..."

  # Descargar archivo de configuración del registro Docker
  if [ ! -f config.yml ]; then
    docker run -it --rm --entrypoint cat registry /etc/docker/registry/config.yml > config.yml
  fi

  # Configurar el archivo de configuración del proxy
  if ! grep -q "proxy:" config.yml; then
    echo "proxy:\n  remoteurl: https://registry-1.docker.io" | tee -a config.yml > /dev/null
  fi

  # Iniciar el contenedor del proxy
  docker run -d --restart=always -p 5000:5000 --name docker-registry-proxy -v "$(pwd)"/config.yml:/etc/docker/registry/config.yml registry
fi

# Detener servicios de Docker para aplicar configuración
echo "Configurando Docker para usar el proxy local..."
systemctl stop docker.socket
systemctl stop docker

# Configurar Docker para usar el proxy como mirror
if [ ! -f /etc/docker/daemon.json ]; then
  echo -e '{\n  "registry-mirrors": ["http://localhost:5000"]\n}' | tee /etc/docker/daemon.json > /dev/null
else
  if ! grep -q '"registry-mirrors": \["http://localhost:5000"\]' /etc/docker/daemon.json; then
    echo -e '{\n  "registry-mirrors": ["http://localhost:5000"]\n}' | tee -a /etc/docker/daemon.json > /dev/null
  fi
fi

# Reiniciar servicios de Docker
systemctl start docker
echo "Proxy local configurado y Docker reiniciado."