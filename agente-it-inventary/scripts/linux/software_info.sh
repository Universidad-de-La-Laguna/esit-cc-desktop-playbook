#!/bin/bash

python_dependencies=$(pip freeze | sed ':a;N;$!ba;s/\n/\\n/g' | sed 's/"/\\"/g')

json_output=$(cat <<EOF
{
  "result": [
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
