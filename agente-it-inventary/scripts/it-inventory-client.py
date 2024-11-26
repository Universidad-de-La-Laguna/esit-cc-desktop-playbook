import json
import os
import platform
import socket
import subprocess
import uuid
import http.client
from pathlib import Path
from typing import Optional

from verifiers import FIELD_VERIFIERS


def get_computer_id() -> str:
    hostname = socket.gethostname()
    system_name = platform.system()
    mac = ':'.join(['{:02x}'.format((uuid.getnode() >> i) & 0xff) for i in range(0, 8*6, 8)][::-1])
    return "-".join([hostname.lower(), system_name.lower(), mac])


HOST = "10.6.7.16:8000"
RESULTS_ENDPOINT = "/save-commands-results/"
COMMANDS_PATH_BASE = "."
COMPUTER_ID = get_computer_id()
COMPUTER_SYSTEM = platform.system().lower()


def get_commands(verbose: bool = False) -> list[str]:
    if verbose:
        print("Get commands for:", COMPUTER_ID)

    directory = Path(COMMANDS_PATH_BASE) / COMPUTER_SYSTEM
    return [
        str(file_in_directory.resolve())
        for file_in_directory in directory.iterdir() if file_in_directory.is_file()
    ]


def run_commands(commands):
    results = []
    for command in commands:
        command_result = run_single_command(command)

        if command_result["status"] == "OK":
            for single_result in command_result["result"]:
                if alert := get_field_alert(
                        field=single_result["field"],
                        value=single_result["value"],
                        computer_id=COMPUTER_ID
                ):
                    single_result["alert"] = alert
        else:
            print()
            print(f"Error en \"{command}\":")
            print(command_result["error"])
            print()

        results.append(command_result)
    send_results(results)


def run_single_command(command) -> dict:
    _, file_extension = os.path.splitext(command)
    app = {
        ".py": "python3",
        ".sh": "bash",
        ".ps1": "powershell -ExecutionPolicy Bypass -File",
        ".vbs": "cscript",
    }.get(file_extension, "bash")

    try:
        process_result = subprocess.run(f"{app} {command}", shell=True, capture_output=True, text=True, check=True)
        process_output = json.loads(process_result.stdout)
        return {
            "computer_id": COMPUTER_ID,
            "command_path": command,
            "result": process_output["result"],
            "status": "OK",
        }
    except (subprocess.CalledProcessError, KeyboardInterrupt, Exception) as e:
        return {
            "computer_id": COMPUTER_ID,
            "command_path": command,
            "result": [],
            "status": "KO",
            "error": str(e),
        }


def get_field_alert(field, value, computer_id) -> Optional[str]:
    if verifier := FIELD_VERIFIERS.get(field):
        return verifier(value, computer_id=computer_id)


def send_results(results):
    headers = {"Content-Type": "application/json"}
    connection = http.client.HTTPConnection(HOST)
    connection.request("POST", RESULTS_ENDPOINT, json.dumps(results), headers=headers)
    connection.getresponse()


def run_on_boot(verbose: bool = False):
    commands = get_commands(verbose=verbose)
    if commands:
        if verbose:
            print("Commands:", commands)
        run_commands(commands)


if __name__ == "__main__":
    run_on_boot(verbose=True)
