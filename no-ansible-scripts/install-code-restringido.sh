#!/bin/bash
# This script installs nvm (Node Version Manager) and Node.js on a Linux system.
echo ==========================================
hostanme
echo ==========================================


cd /opt
rm -f /opt/vscode-fixed.tar.gz
rm -Rf /opt/vscode-fixed
#wget http://cc.etsii.ull.ess/ftp/packages/vscode-fixed.tar.gz 
wget  -q http://10.6.7.11:9393/ftp/packages/vscode-fixed.tar.gz
tar -xf vscode-fixed.tar.gz

chown root /opt/vscode-fixed/chrome-sandbox
chmod 4755 /opt/vscode-fixed/chrome-sandbox


ln -s  /opt/vscode-fixed/code-restringido /usr/local/bin/code-restringido

rm -f /etc/profile
cd /etc/
wget -q https://raw.githubusercontent.com/Universidad-de-La-Laguna/esit-cc-desktop-playbook/refs/heads/master/no-ansible-scripts/profile
chmod a+r /etc/profile


curl -s -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.2/install.sh | NVM_DIR=/usr/local/nvm bash
chmod -R a+rw /usr/local/nvm
export NVM_DIR=/usr/local/nvm
source /usr/local/nvm/nvm.sh


nvm install v24.14.0 >/dev/null 2>&1
npm install -g typescript >/dev/null 2>&1
nvm alias default node >/dev/null 2>&1
nvm use default


