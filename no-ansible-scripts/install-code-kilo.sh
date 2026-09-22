#!/bin/bash

# This script installs nvm (Node Version Manager) and Node.js on a Linux system.
echo ==========================================
hostname
echo ==========================================

mkdir -p /opt/code-extensions
cp -a /etc/esit-cc-desktop-playbook/no-ansible-scripts/code-extensions /opt/
#cp -a /home/carlos/esit-cc-desktop-playbook/no-ansible-scripts/code-extensions /opt/
#cd /opt/code-extensions
#wget  -q https://ftp.esit.ull.es/ftp/packages/kilocode.kilo-code-7.7.7.vsix

cat > /usr/local/bin/code-kilo << 'EOF'
DEST="/opt/VSCode-linux-x64"
EXT="/opt/code-extensions"
rm -Rf $HOME/.vscode

mkdir -p $HOME/.config/Code/User

cp $EXT/settings.json  $HOME/.config/Code/User/settings.json

cd $DEST

$DEST/bin/code \
--install-extension kilocode.kilo-code \
&& $DEST/bin/code
EOF

chmod +x /usr/local/bin/code-kilo


cd /opt
rm -f /opt/vscode-fixed.v1.138.tar.gz
rm -Rf /opt/VSCode-linux-x64
wget  -q https://ftp.esit.ull.es/ftp/packages/vscode-fixed.v1.138.tar.gz
tar -xf vscode-fixed.v1.138.tar.gz

chown root /opt/VSCode-linux-x64/chrome-sandbox
chmod 4755 /opt/VSCode-linux-x64/chrome-sandbox

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



