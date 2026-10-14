#!/usr/bin/env bash

CONFIG="/etc/update-manager/release-upgrades"
HOSTNAME=$(hostname)

if sed -i 's/^Prompt=.*/Prompt=never/' "$CONFIG" &&
   grep -qx 'Prompt=never' "$CONFIG"; then
    printf '\033[32m[OK]\033[0m %s: Prompt=never\n' "$HOSTNAME"
else
    printf '\033[31m[ERROR]\033[0m %s: No se pudo verificar Prompt=never\n' "$HOSTNAME" >&2
    exit 1
fi