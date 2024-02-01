#!/bin/bash

# Instala docker en modo rootless.
# Modificada script de inicio con PAM.

# desinstalar cualquier cosa que tenga docker por apt

for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do apt-get remove $pkg; done

# Set up Docker's apt repository.
 # Add Docker's official GPG key:
apt-get update
apt-get install ca-certificates curl gnupg
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
chmod a+r /etc/apt/keyrings/docker.gpg

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  tee /etc/apt/sources.list.d/docker.list > /dev/null
apt-get update

# Install the Docker packages.
apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Verify that the Docker Engine installation is successful by running the hello-world image.
docker run hello-world

# On Debian and Ubuntu, the Docker service starts on boot by default.
# sudo systemctl enable docker.service
# sudo systemctl enable containerd.service
systemctl disable docker.service
systemctl disable containerd.service

# ROOTLESS Mode
apt-get install -y dbus-user-session 
apt-get install -y uidmap


insertar_si_no_existe() {
    local nueva_linea="$1"
    local archivo="$2"
    grep -qxF "$nueva_linea" "$archivo" || echo "$nueva_linea" >> "$archivo"
}


#echo 'echo $PAM_USER:100000:65536 > /etc/subuid' >> /usr/share/libpam-script/pam_script_auth
insertar_si_no_existe "echo $PAM_USER:100000:65536 > /etc/subuid" "/usr/share/libpam-script/pam_script_auth"

#echo 'echo $PAM_USER:100000:65536 > /etc/subgid' >> /usr/share/libpam-script/pam_script_auth
insertar_si_no_existe "echo $PAM_USER:100000:65536 > /etc/subgid" "/usr/share/libpam-script/pam_script_auth"

# apt-get install -y docker-ce-rootless-extras
# Ejectua as non-root user to set up the daemon
echo '/usr/bin/dockerd-rootless-setuptool.sh install' >> /usr/share/libpam-script/pam_script_auth

# Uso
#
# systemctl --user start docker
# Starting Rootless Docker as a systemd-wide service (/etc/systemd/system/docker.service) is not supported, even with the User= directive.

# You need to specify either the socket path or the CLI context explicitly.
insertar_si_no_existe "export DOCKER_HOST=unix://$XDG_RUNTIME_DIR/docker.sock" "/usr/share/libpam-script/pam_script_auth"

#cat >~/.docker/config.json<< EOF
#{
#  "auths": {
#    "localhost:5000": {}
#  },
#  "HttpHeaders": {
#    "Host": "localhost:5000"
#  }
#}
#EOF

# docker context use rootless
# rootless
# Current context is now "rootless"
# docker run -d -p 8080:80 nginx

# Ejecutamos un registry local en contexto default. Debe ser como root.
docker run -d -p 5000:5000 --restart=always --name registry registry:2
# docker run -d --name mirror -v /tmp:/registry -e STORAGE_PATH=/registry -e STANDALONE=false -e MIRROR_SOURCE=https:/registry-1.docker.io -e MIRROR_SOURCE_INDEX=https://index.docker.io -p 5555:5000 registry

cat >/etc/docker/daemon.json<< EOF
{
  "insecure-registries": ["localhost:5000"]
}
EOF


## docker build https://github.com/docker/rootfs.git#contenedor:docker

#docker container run -d --restart=unless-stopped --name registry \
#  -e "REGISTRY_STORAGE_FILESYSTEM_ROOTDIRECTORY=/var/lib/registry" \
#  -e "REGISTRY_STORAGE_DELETE_ENABLED=true" \
#  -e "REGISTRY_VALIDATION_DISABLED=true" \
#  -e "REGISTRY_PROXY_REMOTEURL=https://registry-1.docker.io" \
#  -v "registry-data:/var/lib/registry" \
#  -p "127.0.0.1:5000:5000" \
#  registry:2
#
#
#docker container run -d --restart=unless-stopped --name registry \
#  -e "REGISTRY_PROXY_REMOTEURL=https://registry-1.docker.io" \
#  -p "127.0.0.1:5000:5000" \
#  registry:2


