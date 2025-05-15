#!/bin/bash
# This script installs nvm (Node Version Manager) and Node.js on a Linux system.



curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.2/install.sh | NVM_DIR=/usr/local/nvm bash
chmod -R a+rw /usr/local/nvm
nvm install v20.11.1
npm install -g typescript
nvm alias default node
nvm use default
