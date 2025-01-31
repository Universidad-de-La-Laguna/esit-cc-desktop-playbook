import socket
import json
import platform
from subprocess import check_output
import re
import psutil


def get_memory_slots():
    try:
        output = check_output(["wmic", "memorychip", "list", "full"]).decode("utf-8").split("\n")
        slots = []
        slot_number = 1
        for line in output:
            if "Capacity" in line or "Speed" in line or "MemoryType" in line:
                size = re.search(r"Capacity=(\d+)", line)
                speed = re.search(r"Speed=(\d+)", line)
                memory_type = re.search(r"MemoryType=(\d+)", line)

                slot_info = {
                    "Size": f"SLOT {slot_number} Size: {int(size.group(1)) // (1024**3) if size else 'Unknown'}GB",
                    "Speed": f"SLOT {slot_number} Speed: {speed.group(1) + 'MHz' if speed else 'Unknown'}",
                    "Type": f"SLOT {slot_number} Type: {memory_type.group(1) if memory_type else 'Unknown'}",
                }
                slots.append(slot_info)
                slot_number += 1
        return slots
    except Exception as e:
        return []



def get_windows_security_updates():
    try:
        installed_updates = subprocess.check_output("wmic qfe list brief", shell=True, text=True)
        pending_updates = subprocess.check_output("wmic qfe list | findstr /I \"KB\"", shell=True, text=True)
      
        return (pending_updates.strip() if pending_updates else "No se encontraron actualizaciones pendientes.")
   
    except subprocess.CalledProcessError:
        return ("Error al obtener las actualizaciones.")

def get_system_info():
    memory_slots = get_memory_slots()
    computer_model = platform.node()
    cpu_model = platform.processor()
    memory = psutil.virtual_memory().total / (1024**3)
    disk_info = psutil.disk_usage('/')
    disk = disk_info.free / (1024**3)
    ip_address = socket.gethostbyname(socket.gethostname())
    os_name = platform.system()
    os_full = platform.platform()
    os_release = platform.version()

    windows_security_updates="no"
    
    json_output = {
        "result": [
            {
                "field": "Modelo de equipo",
                "value": computer_model,
                "data_group": "hardware",
                "not_show": "true",
            },
            {
                "field": "CPU",
                "value": cpu_model,
                "data_group": "hardware",
                "not_show": "true",
            },
            {
                "field": "Ram memory",
                "value": f"{memory:.2f} GB",
                "data_group": "hardware",
            },
            {
                "field": "Memory slots",
                "value": "\n".join(slot["Size"] for slot in memory_slots),
                "data_group": "hardware",
                "not_show": "true",
            },
            {
                "field": "Memory slots speed",
                "value": "\n".join(slot["Speed"] for slot in memory_slots),
                "data_group": "hardware",
                "not_show": "true",
            },
            {
                "field": "Memory slots type",
                "value": "\n".join(slot["Type"] for slot in memory_slots),
                "data_group": "hardware",
                "not_show": "true",
            },
            {
                "field": "Hard disc",
                "value": f"{disk:.2f} GB",
                "data_group": "hardware",
            },
            {
                "field": "IP",
                "value": ip_address,
                "data_group": "network",
            },
            {
                "field": "OS",
                "value": os_name,
                "data_group": "system",
                "not_show": "true",
            },
            {
                "field": "OS Fullname",
                "value": os_full,
                "data_group": "system",
            },
            {
                "field": "OS release",
                "value": os_release,
                "data_group": "system",
            },
            {
                "field": "Windows security updates",
                "value": windows_security_updates,
                "data_group": "system",
                "not_show": "false"
            }
        ]

    }

    return json.dumps(json_output, indent=2)

if __name__ == "__main__":
    system_info_json = get_system_info()
    print(system_info_json)


