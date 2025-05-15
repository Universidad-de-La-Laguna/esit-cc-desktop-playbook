#!/bin/bash
# This script installs nvm (Node Version Manager) and Node.js on a Linux system.
chmod -R a+rw /usr/local/nvm
nvm install v20.11.1
npm install -g typescript
nvm alias default node
nvm use default