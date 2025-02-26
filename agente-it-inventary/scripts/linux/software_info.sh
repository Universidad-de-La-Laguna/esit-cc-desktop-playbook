#!/bin/bash

linux_software=$(dpkg -l | awk '/^ii/ {print $2 " [" $3 "]"}' | sed ':a;N;$!ba;s/\n/\\n/g')
python_dependencies=$(pip freeze | sed ':a;N;$!ba;s/\n/\\n/g' | sed 's/"/\\"/g')
docker_version=$(docker --version 2>/dev/null || echo 0) # Muestra la versión de Docker si está instalado; devuelve 0 si no lo está.
gedit_numero_complementos=$(dpkg -l | grep "ii\ \ gedit-*" | wc -l) #305 #albham
code_version=$(dpkg -l | grep "^ii  code " | awk '{print $3}')
security_updates=$(apt list --upgradable 2>/dev/null | grep -i security | wc -l)

json_output=$(cat <<EOF
{
  "result": [
    {
      "field": "Librerias Python instaladas",
      "value": "$python_dependencies",
      "data_group": "software",
      "not_show": "true"
    },
    {
      "field": "Docker version",
      "value": "$docker_version",
      "data_group": "A2025",
      "not_show": "true"
    },
    {
      "field": "Gedit numero complementos",
      "value": "$gedit_numero_complementos",
      "data_group": "A2025",
      "not_show": "true"
    },
    {
      "field": "Code version",
      "value": "$code_version",
      "data_group": "A2025",
      "not_show": "false"
    },
{
      "field": "Security updates",
      "value": "$security_updates",
      "data_group": "A2025",
      "not_show": "false"
    }            
  ]
}
EOF
)

echo "$json_output"
