#!/bin/bash
# This script installs nvm (Node Version Manager) and Node.js on a Linux system.
echo ==========================================
hostname
echo ==========================================

cat > /usr/local/bin/code-restringido2 << 'EOF'
DEST="/opt/vscode-fixed.v1.119"
rm -Rf ~/.vscode
cd $DEST
$DEST/code --extensions-dir "$DEST/extensions-fixed" --user-data-dir "$DEST/userdata-fixed"
EOF
chmod +x /usr/local/bin/code-restringido2


cd /opt
rm -f /opt/vscode-fixed.v1.119.tar.gz
rm -Rf /opt/vscode-fixed.v1.119
wget  -q http://10.6.7.11:9393/ftp/packages/vscode-fixed.v1.119.tar.gz
tar -xf vscode-fixed.v1.119.tar.gz

chown root /opt/vscode-fixed.v1.119/chrome-sandbox
chmod 4755 /opt/vscode-fixed.v1.119/chrome-sandbox

ln -s  /opt/vscode-fixed.v1.119/code-restringido2 /usr/local/bin/code-restringido2

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

