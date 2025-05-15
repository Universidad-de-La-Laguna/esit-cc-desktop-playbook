#!/bin/bash
# This script installs nvm (Node Version Manager) and Node.js on a Linux system.


cat > /etc/profile <<EOF

# /etc/profile: system-wide .profile file for the Bourne shell (sh(1))
# and Bourne compatible shells (bash(1), ksh(1), ash(1), ...).

if [ "${PS1-}" ]; then
  if [ "${BASH-}" ] && [ "$BASH" != "/bin/sh" ]; then
    # The file bash.bashrc already sets the default PS1.
    # PS1='\h:\w\$ '
    if [ -f /etc/bash.bashrc ]; then
      . /etc/bash.bashrc
    fi
  else
    if [ "$(id -u)" -eq 0 ]; then
      PS1='# '
    else
      PS1='$ '
    fi
  fi
fi

if [ -d /etc/profile.d ]; then
  for i in /etc/profile.d/*.sh; do
    if [ -r $i ]; then
      . $i
    fi
  done
  unset i
fi

EOF

curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.2/install.sh | NVM_DIR=/usr/local/nvm bash
chmod -R a+rw /usr/local/nvm
nvm install v20.11.1
npm install -g typescript
nvm alias default node
nvm use default
