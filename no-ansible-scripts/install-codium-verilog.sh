#!/bin/bash
# This script installs nvm (Node Version Manager) and Node.js on a Linux system.
echo ==========================================
hostname
echo ==========================================

mkdir -p /opt/code-extensions
cp -a /etc/esit-cc-desktop-playbook/no-ansible-scripts/code-extensions /opt/

cat > /usr/local/bin/codium-verilog << 'EOF'
DEST="/opt/vscodium-v1.116"
EXT="/opt/code-extensions"
rm -Rf $HOME/.vscode

mkdir -p $HOME/.config/VSCodium/User
cp $EXT/settings.json  $HOME/.config/VSCodium/User/settings.json

cd $DEST

$DEST/bin/codium \
--install-extension $EXT/verilog-hdl-systemverilog-1.29.0.vsix \
&& $DEST/bin/codium
EOF

chmod +x /usr/local/bin/codium-verilog

mkdir -p /opt/vscodium-v1.116
cd /opt/vscodium-v1.116
wget  -q http://10.6.7.11:9393/ftp/packages/VSCodium-linux-x64-1.116.02821.tar.gz
tar -xf VSCodium-linux-x64-1.116.02821.tar.gz
rm -f VSCodium-linux-x64-1.116.02821.tar.gz
chown root /opt/vscodium-v1.116/chrome-sandbox
chmod 4755 /opt/vscodium-v1.116/chrome-sandbox

