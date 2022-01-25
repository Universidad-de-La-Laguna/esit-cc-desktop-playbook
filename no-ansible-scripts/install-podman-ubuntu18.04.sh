#!/bin/bash

# Instalación de podman en Ubuntu 18.04 el salas del CC
# algunas diferencias con Ubuntu 20.04


apt-get install curl wget gnupg2 -y
. /etc/os-release
echo 'deb http://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/xUbuntu_${VERSION_ID}/ /' > /etc/apt/sources.list.d/devel:kubic:libcontainers:stable.list
wget -nv https://download.opensuse.org/repositories/devel:kubic:libcontainers:stable/xUbuntu_${VERSION_ID}/Release.key -O- | apt-key add -
apt-get update -qq -y
apt-get -qq --yes install podman buildah skopeo
podman --version

# El kernel no soporta 
cp /etc/containers/storage.conf /etc/containers/storage.conf.ori
sed -i 's/mountopt = "nodev,metacopy=on"/mountopt = "nodev,metacopy=off"/g' /etc/containers/storage.conf 

podman info

# Para ejecutar en modo rootless es necesario mapeo de uid y gid

cat > /usr/local/bin/crea-ficheros-subuid-subguid.py <<EOF
#!/usr/bin/python
f = open("/etc/subuid", "w")
for uid in range(1000, 65536):
    f.write("%d:%d:65536\n" %(uid,uid*65536))
f.close()

f = open("/etc/subgid", "w")
for uid in range(1000, 65536):
    f.write("%d:%d:65536\n" %(uid,uid*65536))
f.close()
EOF

chmod go-rwx,u+rwx /usr/local/bin/crea-ficheros-subuid-subguid.py
/usr/local/bin/crea-ficheros-subuid-subguid.py

# configuraciones para que podman sea usable de vs code

# Se debe establecer en Code Preferences > Settings > docker.host
# a unix:///run/user/1000/podman/podman.sock donde 1000 es el uid.
# O por la variable de entorno DOCKER_HOST
#cat >/etc/profile.d/docker-code.sh << EOF
#export DOCKER_HOST="unix:///run/user/$(id -u)/podman/podman.sock"
#EOF

echo "" >> /etc/profile
echo 'systemctl --user enable --now podman.socket' >> /etc/profile
#systemctl --user enable --now podman.socket
echo 'LOGUID=`id -u ${USER}` ' >> /etc/profile
echo 'export DOCKER_HOST="unix:///run/user/${LOGUID}/podman/podman.sock"' >> /etc/profile
podman-remote info


# Hacemos creer a Code que Podman es Docker. Ojo, un alias no funciona.
# rm -f /usr/bin/docker
#mv /usr/bin/docker /usr/bin/docker.ori
apt purge -y docker-ce*
ln -s /usr/bin/podman /usr/bin/docker

# Instalar extensión de Docker en Code


# para reconocer el mapeo de uid es necesario reiniciar
reboot

