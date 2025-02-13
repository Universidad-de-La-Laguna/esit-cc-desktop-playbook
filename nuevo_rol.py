import os
import argparse


class RoleManager:
    ROLE_PATH = "./roles"
    PLAYBOOK_PATH = "./Ubuntu22.04.yml"
    TASKS = "tasks"
    TASKS_FILE = "main.yml"
    NEW_ROLE_TEMPLATE = """# === TASKS DEL ROL ===
- name: Primera task para el rol %s
  # Aquí falta añadir la tarea del rol

"""
    TEMPLATE_FOR_RUN_ONCE = """# === FLAG ===
- name: Definición de la variable del fichero flag
  set_fact:
    flag_path: "/etc/executed_scripts/%(role_name)s-1"  # Incrementar el índice para forzar la ejecución del rol

- name: "Verificar si el rol ha sido ejecutado"
  stat:
    path: "{{ flag_path }}"
  register: flagfile

- name: "Abortar si el rol ha sido ya ejecutado"
  meta: end_play
  when: flagfile.stat.exists

%(role_template)s
# === FLAG ===
- name: "Crear flag indicando que el rol ha sido ejecutado"
  file:
    path: "{{ flag_path }}"
    state: touch
    mode: '0644'
"""

    def create_new_role(self, role_name, onboot, run_once=False):
        final_role_name = role_name.lower().replace(" ", "-")
        tasks_path = self._create_new_role_tree_structure(final_role_name)
        self._create_new_role_tasks_file(final_role_name, tasks_path, run_once)
        self._insert_new_rol_in_the_playbook(final_role_name, onboot)
        print("Rol creado.")

    def _create_new_role_tree_structure(self, role_name):
        role_path = os.path.join(self.ROLE_PATH, role_name)
        os.makedirs(os.path.join(role_path, self.TASKS), exist_ok=True)
        return os.path.join(role_path, self.TASKS)

    def _create_new_role_tasks_file(self, role_name, tasks_path, run_once):
        with open(os.path.join(tasks_path, self.TASKS_FILE), "w") as f:
            template = self.NEW_ROLE_TEMPLATE % role_name
            if run_once:
                template = self.TEMPLATE_FOR_RUN_ONCE % {"role_name": role_name, "role_template": template}
            f.write(template)

    def _insert_new_rol_in_the_playbook(self, role_name, onboot):
        new_role_line = f"- {{ role: {role_name}, tags: ['{role_name}'{", 'onboot'" if onboot else ""}] }}"

        with open(self.PLAYBOOK_PATH, "r") as file:
            lines = file.readlines()

        for i, line in enumerate(lines):
            if "role: executed-scripts-flag-directory" in line:
                lines.insert(i + 1, "    " + new_role_line + "\n")
                break

        with open(self.PLAYBOOK_PATH, "w") as file:
            file.writelines(lines)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Script para la creación de nuevos roles")
    parser.add_argument("rol", help="Nombre del nuevo rol")
    parser.add_argument(
        "--onboot",
        action="store_true",
        help="Agregar este parámetro para que el rol se ejecute en el arranque del equipo")
    parser.add_argument(
        "--run-once",
        action="store_true",
        help="Agregar este parámetro para que el rol no se ejecute, una vez ya haya sido ejecutado")

    args = parser.parse_args()
    RoleManager().create_new_role(role_name=args.rol, onboot=args.onboot, run_once=args.run_once)
