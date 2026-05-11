#!/bin/bash
# This script installs nvm (Node Version Manager) and Node.js on a Linux system.
echo ==========================================
hostname
echo ==========================================

mkdir -p /opt/code-extensions
cp -a /etc/esit-cc-desktop-playbook/no-ansible-scripts/code-extensions /opt/

cat > /usr/local/bin/code-restringido2 << 'EOF'
DEST="/opt/vscode-fixed.v1.119"
EXT="/opt/code-extensions"
rm -Rf ~/.vscode

cp $EXT/settings.json  ~/.config/Code/settings.json

cd $DEST
$DEST/bin/code \
--install-extension $EXT/ms-vscode-remote.remote-ssh-0.122.0.vsix \
--install-extension $EXT/ms-vscode-remote.remote-ssh-edit-0.87.0.vsix \
--install-extension $EXT/dbaeumer.vscode-eslint-3.0.24.vsix \
--install-extension $EXT/esbenp.prettier-vscode-12.4.0.vsix \
--install-extension $EXT/mongodb.mongodb-vscode-1.16.0.vsix \
--install-extension $EXT/ms-vscode.live-server-0.4.18.vsix \
--install-extension $EXT/vitest.explorer-1.50.4.vsix \
--install-extension $EXT/postman.postman-for-vscode-1.19.1.vsix  \
&& $DEST/code
EOF

chmod +x /usr/local/bin/code-restringido2


cd /opt
rm -f /opt/vscode-fixed.v1.119.tar.gz
rm -Rf /opt/vscode-fixed.v1.119
wget  -q http://10.6.7.11:9393/ftp/packages/vscode-fixed.v1.119.tar.gz
tar -xf vscode-fixed.v1.119.tar.gz

chown root /opt/vscode-fixed.v1.119/chrome-sandbox
chmod 4755 /opt/vscode-fixed.v1.119/chrome-sandbox

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


