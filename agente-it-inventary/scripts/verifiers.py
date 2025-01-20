def ip_checker(value, **kwargs):
    ip = value
    return None


def hard_disc_checker(value, **kwargs):
    import re

    threshold = 500  # Gb
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
    if docker_version == "0":
        return "Docker no instalado" 

    import re
    match = re.search(r"(\d+\.\d+\.\d+)", docker_version)
    if not match:
        return "Versión desconocida"

    version_major = match.group(1).split('.')[0]
    if int(version_major) < 27:
        return "Versión obsoleta" 

def check_gedit (gedit_numero_complementos, **kwargs):
    print (gedit_numero_complementos)
    if int (gedit_numero_complementos) < 26:
        return "Revisar los complementos de gedit. Son menos de 26" 

def check_vivado (is_vivado_2023_installed, **kwargs):
    if is_vivado_2023_installed=="NO" and hostname.startswith(("cc14", "cc11", "cc24")):
        return "Revisar instalacion de Vivado 2023. Debe estar instalado en 11,14 y 24"


def check_code_version (code_version, **kwargs):
    from packaging.version import Version
    # Versión mínima requerida
    MIN_VERSION = "1.96.0"
    INSTALLED_VERSION = code_version

    # Comparar versiones
    if Version(INSTALLED_VERSION) >= Version(MIN_VERSION):
        return(f"La versión instalada ({INSTALLED_VERSION}) cumple con el requisito mínimo ({MIN_VERSION}).")



FIELD_VERIFIERS = {
    # "IP": ip_checker,
    #"Hard disc": hard_disc_checker,
    "Docker version": check_docker,
    "Gedit numero complementos": check_gedit,
    "Vivado":check_vivado,
    "Code version":check_code_version
}
