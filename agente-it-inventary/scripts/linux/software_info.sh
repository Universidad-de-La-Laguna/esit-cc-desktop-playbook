#!/bin/bash

linux_software=$(dpkg -l | awk '/^ii/ {print $2 " [" $3 "]"}' | sed ':a;N;$!ba;s/\n/\\n/g')
python_dependencies=$(pip freeze | sed ':a;N;$!ba;s/\n/\\n/g' | sed 's/"/\\"/g')

json_output=$(cat <<EOF
{
  "result": [
    {
      "field": "Software de Linux",
      "value": "$linux_software",
      "data_group": "software",
      "not_show": "true"
    },
    {
      "field": "Librerias Python instaladas",
      "value": "$python_dependencies",
      "data_group": "software",
      "not_show": "true"
    }
  ]
}
EOF
)

echo "$json_output"
