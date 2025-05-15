#!/bin/bash
# This script installs nvm (Node Version Manager) and Node.js on a Linux system.

cd /opt
wget http://cc.etsii.ull.es/ftp/packages/vscode-fixed.tar.gz 
tar -xvzf vscode-fixed.tar.gz
ln -s  /opt/vscode-fixed/code-restringido /usr/local/bin/code-restringido

rm -f /etc/profile
cd /etc/
wget https://raw.githubusercontent.com/Universidad-de-La-Laguna/esit-cc-desktop-playbook/refs/heads/master/no-ansible-scripts/profile
chmod a+r /etc/profile


curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.2/install.sh | NVM_DIR=/usr/local/nvm bash
chmod -R a+rw /usr/local/nvm
export NVM_DIR=/usr/local/nvm
source /usr/local/nvm/nvm.sh


nvm install v20.11.1
npm install -g typescript
nvm alias default node
nvm use default


