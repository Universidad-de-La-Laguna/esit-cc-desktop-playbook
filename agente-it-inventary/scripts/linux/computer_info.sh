#!/bin/bash

function revisar_slots_memoria {
    local slots
    slots=$(dmidecode -t memory)
    local slot_number=1
    # Iterar sobre cada slot de memoria encontrado
    while read -r line; do
        if [[ "$line" =~ ^[[:space:]]*Size: ]]; then
            slot_memoria_size+="SLOT $slot_number Size: $(echo "$line" | awk '{print $2$3}')\n"
            ((slot_number++))
        fi
    done <<< "$slots"

    slot_number=1

    while read -r line; do
        if [[ $line =~ ^[[:space:]]*Speed: ]]; then
            slot_memoria_speed+="SLOT $slot_number Speed: $(echo "$line" | awk '{print $2$3}')\n"
            ((slot_number++))
        fi
    done <<< "$slots"

    slot_number=1

    while read -r line; do
        if [[ $line =~ ^[[:space:]]*Type: ]]; then
            slot_memoria_type+="SLOT $slot_number Type: $(echo "$line" | awk '{$1=""; print $0}')\n"
            ((slot_number++))
        fi
    done <<< "$slots"
}

# Información de cada slot de memoria
revisar_slots_memoria

computer_model=$(dmidecode -s system-product-name)
computer_cpu=$(dmidecode -t processor | awk -F ': ' '/Version/{print $2}')
memory=$(free -h | awk '/Mem:/ {print $2}')
disk=$(df -h --output=size --total | tail -1 | xargs)
disk_model=$(fdisk -l | grep "Disk model" )
disk_partitions=$(df -h | grep "^/dev" | tr '\n' ' | ')
ip_address=$(hostname -I | awk '{print $1}')
ip_type=$(ip route | awk '/default/ {print $5}' | xargs -I {} ip addr show dev {} | grep -q 'dynamic' && echo "Dinámica" || echo "Estática")
os_name=$(uname -s)
os_full=$(lsb_release -d -s)
os_release=$(uname -r)
users_loggedin_this_year=$(last -Fw | grep -vE '^(root|reboot)' | grep "$(date +'%Y')" | wc -l)
free_space_gb=$(df -h / | awk 'NR==2 {print $4}' | sed 's/G//')

json_output=$(cat <<EOF
{
  "result": [
    {
      "field": "Modelo de equipo",
      "value": "$computer_model",
      "data_group": "hardware",
      "not_show": "false"
    },
    {
      "field": "CPU",
      "value": "$computer_cpu",
      "data_group": "hardware",
      "not_show": "true"
    },
    {
      "field": "Ram memory",
      "value": "$memory",
      "data_group": "hardware"
    },
    {
      "field": "Memory slots size",
      "value": "$slot_memoria_size",
      "data_group": "hardware",
      "not_show": "false"
    },
    {
      "field": "Memory slots speed",
      "value": "$slot_memoria_speed",
      "data_group": "hardware",
      "not_show": "true"
    },
    {
      "field": "Memory slots type",
      "value": "$slot_memoria_type",
      "data_group": "hardware",
      "not_show": "false"
    },
    {
      "field": "Hard disc",
      "value": "$disk",
      "data_group": "hardware"
    },
        {
      "field": "Free space gb",
      "value": "$free_space_gb",
      "data_group": "hardware",
      "not_show": "false"
    },
    {
      "field": "Hard disc model",
      "value": "$disk_model",
      "data_group": "hardware",
      "not_show": "true"
    },
    {
      "field": "Hard disc partitions",
      "value": "$disk_partitions",
      "data_group": "hardware",
      "not_show": "true"
    },
    {
      "field": "IP",
      "value": "$ip_address",
      "data_group": "network"
    },
    {
      "field": "IP - tipo",
      "value": "$ip_type",
      "data_group": "network"
    },
    {
      "field": "OS",
      "value": "$os_name",
      "data_group": "system",
      "not_show": "true"
    },
    {
      "field": "OS Fullname",
      "value": "$os_full",
      "data_group": "system"
    },
    {
      "field": "OS release",
      "value": "$os_release",
      "data_group": "system"
    },
    {
      "field": "Usuarios en $(date +'%Y')",
      "value": "$users_loggedin_this_year",
      "data_group": "system"
    }
  ]
}
EOF
)

echo "$json_output"
