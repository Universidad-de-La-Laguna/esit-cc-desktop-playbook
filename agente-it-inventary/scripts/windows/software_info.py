import json
import subprocess

try:
    result = subprocess.run(["pip", "freeze"], capture_output=True, text=True, check=True)
    python_dependencies = result.stdout.strip().replace("\n", " ")
except subprocess.CalledProcessError as e:
    print(f"Error al ejecutar pip freeze: {e}")
    python_dependencies = ""

python_dependencies = python_dependencies.replace('"', '\\"')

json_output = {
    "result": [
        {
            "field": "Librerias Python instaladas",
            "value": python_dependencies,
            "data_group": "software",
            "not_show": "true"
        }
    ]
}

json_formatted = json.dumps(json_output, indent=2)
print(json_formatted)
