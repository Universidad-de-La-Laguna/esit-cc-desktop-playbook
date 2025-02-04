import json
import subprocess

def get_installed_software():
    try:
        result = subprocess.run(
            ["wmic", "product", "get", "name"],
            capture_output=True, text=True, check=True
        )
        software_list = [line.strip() for line in result.stdout.split("\n") if line.strip() and "Name" not in line]
        software_list.sort()
        return "\n".join(software_list)
    except subprocess.CalledProcessError as e:
        print(f"Error al obtener el software instalado: {e}")
        return ""

try:
    result = subprocess.run(
        ["pip", "freeze"], capture_output=True, text=True, check=True
    )

    python_dependencies = result.stdout.strip()
except subprocess.CalledProcessError as e:
    print(f"Error al ejecutar pip freeze: {e}")
    python_dependencies = ""

import os

def get_is_vivado_2023_installed():
    # Ruta al archivo
    path_to_check = r"C:\Xilinx\Vivado\2023.1\bin\vivado.bat"
    # Verificar si existe
    if os.path.exists(path_to_check):
        return("YES")
    else:
        is_vivado_20023_installed="NO"
        return("NO")
    

python_dependencies = python_dependencies.replace('"', '\\"')

installed_software = get_installed_software()

is_vivado_2023_installed = get_is_vivado_2023_installed()


json_output = {
    "result": [
        {
            "field": "Librerias Python instaladas",
            "value": python_dependencies,
            "data_group": "software",
            "not_show": "true"
        },
        {
            "field": "Software Windows",
            "value": installed_software,
            "data_group": "software",
            "not_show": "true"
        },
        {
            "field": "Vivado instalado 2023",
            "value": is_vivado_2023_installed,
            "data_group": "2025",
            "not_show": "true"
        }
    ]
}

json_formatted = json.dumps(json_output, indent=2)
print(json_formatted)

# C:\Xilinx\Vivado/2023.1\bin\vivado.bat