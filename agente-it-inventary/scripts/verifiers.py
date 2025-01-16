def ip_checker(value, **kwargs):
    ip = value
    return None


def hard_disc_checker(value, **kwargs):
    import re

    threshold = 1500  # Gb
    capacity = value.strip()
    match = re.match(r"([\d.,]+)\s*([A-Za-z]+)", capacity)
    if match:
        value, unit = match.groups()

        if ',' in value:
            value = value.replace('.', '')
            value = value.replace(',', '.')
        value = float(value)

        unit = unit.strip().upper()
        if unit in ("GB", "G"):
            if value < threshold:
                return "Demasiado pequeño"
            return None
        elif unit in ("TB", "T"):
            capacity_in_gb = value * 1024
            if capacity_in_gb < threshold:
                return "Demasiado pequeño"
            return None
        elif unit in ("MB", "M"):
            capacity_in_gb = value / 1024
            if capacity_in_gb < threshold:
                return "Demasiado pequeño"
        return f"Unidad desconocida: {unit}"
    else:
        return f"Formato no válido: {capacity}"

def get_computer_room(computer_id):
    import re
    if not re.fullmatch("^cc[1-9]{4}-[A-Za-z0-9]+-[A-Za-z0-9]+$", computer_id):
        return ""  # Invalid hostname
    return ".".join(computer_id[2:4])

def check_docker (docker_version, **kwargs):
    if int (docker_version) == 0:
        return "Docker no instalado" 

    if int (docker_version.split(' ')[2].split('.')[0]) < 27:
        return "Versión obsoleta" 

def check_gedit (gedit_numero_complementos, **kwargs):
    if int (gedit_numero_complementos) < 26:
        return "Revisar los complementos de gedit. Son menos de 26" 


FIELD_VERIFIERS = {
    # "IP": ip_checker,
    "Hard disc": hard_disc_checker,
    "Docker version":check_docker,
    "Gedit numero complementos":check_gedit
}
