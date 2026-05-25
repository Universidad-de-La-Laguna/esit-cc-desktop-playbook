#!/bin/bash
# This script installs nvm (Node Version Manager) and Node.js on a Linux system.
echo ==========================================
hostname
echo ==========================================

mkdir -p /opt/code-extensions
cp -a /etc/esit-cc-desktop-playbook/no-ansible-scripts/code-extensions /opt/

cat > /usr/local/bin/code-restringido-codium << 'EOF'
DEST="/opt/vscodium-v1.116"
EXT="/opt/code-extensions"
rm -Rf $HOME/.vscode

mkdir -p $HOME/.config/VSCodium/User
cp $EXT/settings.json  $HOME/.config/VSCodium/User/settings.json

cd $DEST

$DEST/bin/codium \
--install-extension $EXT/dbaeumer.vscode-eslint-3.0.24.vsix \
--install-extension $EXT/esbenp.prettier-vscode-12.4.0.vsix \
--install-extension $EXT/mongodb.mongodb-vscode-1.16.0.vsix \
--install-extension $EXT/ms-vscode.live-server-0.4.18.vsix \
--install-extension $EXT/vitest.explorer-1.50.4.vsix \
&& $DEST/bin/codium
EOF

#--install-extension $EXT/ms-vscode-remote.remote-ssh-0.122.0.vsix \
#--install-extension $EXT/ms-vscode-remote.remote-ssh-edit-0.87.0.vsix \
#--install-extension $EXT/postman.postman-for-vscode-1.19.1.vsix  \

chmod +x /usr/local/bin/code-restringido-codium

mkdir -p /opt/vscodium-v1.116
cd /opt/vscodium-v1.116
wget  -q http://10.6.7.11:9393/ftp/packages/VSCodium-linux-x64-1.116.02821.tar.gz
tar -xf VSCodium-linux-x64-1.116.02821.tar.gz
rm -f VSCodium-linux-x64-1.116.02821.tar.gz
chown root /opt/vscodium-v1.116/chrome-sandbox
chmod 4755 /opt/vscodium-v1.116/chrome-sandbox

# === Configuración del Manejador de URLs para VSCodium ===

# Crea un archivo de acceso directo (.desktop) en el sistema global.
# Esto permite que el sistema operativo reconozca a VSCodium como una aplicación instalada.
rm -f /usr/share/applications/vscodium.desktop
mkdir -p /usr/share/applications

cat > /usr/share/applications/vscodium.desktop << 'EOF'
[Desktop Entry]
Name=Codium URL Handler
# Define el comando para abrir URLs específicas directamente en VSCodium
Exec=/opt/vscodium-v1.116/bin/codium --open-url %U
Type=Application
Terminal=false
# Registra el protocolo "vscodium://" para que el navegador sepa a qué app llamar
MimeType=x-scheme-handler/vscodium;
EOF

chmod +x /usr/share/applications/vscodium.desktop

xdg-mime default vscodium.desktop x-scheme-handler/vscodium
update-desktop-database /usr/share/applications

rm -f /etc/profile
cd /etc/
wget -q https://raw.githubusercontent.com/Universidad-de-La-Laguna/esit-cc-desktop-playbook/refs/heads/master/no-ansible-scripts/profile
chmod a+r /etc/profile


curl -s -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.4/install.sh | NVM_DIR=/usr/local/nvm bash
chmod -R a+rw /usr/local/nvm
export NVM_DIR=/usr/local/nvm
source /usr/local/nvm/nvm.sh


nvm install v24.15.0 >/dev/null 2>&1
npm install -g typescript >/dev/null 2>&1
nvm alias default node >/dev/null 2>&1
nvm use default

#==== 

