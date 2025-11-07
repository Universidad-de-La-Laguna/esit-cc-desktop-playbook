#!/bin/bash

apt update -y
apt install -y python3.12-dev python3.12-venv
cd /opt
python3.12 -m venv env-sipc
source /opt/env-sipc/bin/activate
python3.12 -m pip install --upgrade pip
python3.12 -m pip install mediapipe pymunk pygame
chmod a+w -R /opt/env-sipc

