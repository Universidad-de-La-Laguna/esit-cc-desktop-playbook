#!/bin/bash

# This script installs nvm (Node Version Manager) and Node.js on a Linux system.
echo ==========================================
hostname
echo ==========================================

#Download Kilo extension if it does not exist

mkdir -p /opt/vscode-extensions
wget -q -O /opt/vscode-extensions/kilo-code-7.7.9.vsix https://open-vsx.org/api/kilocode/kilo-code/linux-x64/7.7.9/file/kilocode.kilo-code-7.7.9@linux-x64.vsix


cat > /usr/local/bin/code-kilo << 'EOF'
DEST="/opt/vscode-fixed.v1.138"
EXT="/opt/vscode-extensions"
SETTINGS="/opt/code-extensions"
rm -Rf $HOME/.vscode

cd $DEST

$DEST/bin/code \
--install-extension  $EXT/kilo-code-7.7.9.vsix \
&& $DEST/bin/code
EOF

chmod +x /usr/local/bin/code-kilo


cd /opt
rm -f /opt/vscode-fixed.v1.138.tar.gz
rm -Rf /opt/VSCode-linux-x64
rm -Rf /opt/vscode-fixed.v1.138
wget  -q https://ftp.esit.ull.es/ftp/packages/vscode-fixed.v1.138.tar.gz
tar -xf vscode-fixed.v1.138.tar.gz

mv /opt/VSCode-linux-x64 /opt/vscode-fixed.v1.138

chown root /opt/vscode-fixed.v1.138/chrome-sandbox
chmod 4755 /opt/vscode-fixed.v1.138/chrome-sandbox

rm -f /etc/profile
cd /etc/
wget -q https://raw.githubusercontent.com/Universidad-de-La-Laguna/esit-cc-desktop-playbook/refs/heads/master/no-ansible-scripts/profile
chmod a+r /etc/profile


curl -s -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.8/install.sh | NVM_DIR=/usr/local/nvm bash
chmod -R a+rw /usr/local/nvm
export NVM_DIR=/usr/local/nvm
source /usr/local/nvm/nvm.sh


nvm install v24.15.0 >/dev/null 2>&1
npm install -g typescript >/dev/null 2>&1
nvm alias default node >/dev/null 2>&1
nvm use default

#==== 



