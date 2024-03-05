import gspread
from oauth2client.service_account import ServiceAccountCredentials
import subprocess

# Definir el alcance y las credenciales del servicio
scope = ['https://spreadsheets.google.com/feeds', 'https://www.googleapis.com/auth/drive']
credentials = ServiceAccountCredentials.from_json_keyfile_name('credentials.json', scope)

# Autenticar con las credenciales
client = gspread.authorize(credentials)

# Abrir la hoja de cálculo por su ID o URL
# (Puedes obtener la ID o URL desde la barra de direcciones del navegador)
spreadsheet = client.open_by_key('ID_de_la_hoja_de_cálculo')

# Seleccionar la hoja específica ("Estado de ordenadores")
worksheet = spreadsheet.worksheet('Estado de ordenadores')

# Obtener los nombres de los ordenadores y sus estados deseados
ordenadores = worksheet.col_values(2)[1:]  # Ignorar la primera fila (encabezado)
estados_deseados = worksheet.col_values(4)[1:]  # Ignorar la primera fila (encabezado)

# Combinar los nombres de los ordenadores y sus estados deseados en un diccionario
estado_por_ordenador = dict(zip(ordenadores, estados_deseados))

# Verificar el estado deseado y la cantidad de usuarios conectados para cada ordenador
for nombre_ordenador, estado_deseado in estado_por_ordenador.items():
    # Verificar el estado deseado
    if estado_deseado == "APAGADO":
        # Verificar la cantidad de usuarios conectados
        usuarios_logueados = int(subprocess.check_output(["who", "-q"]).split()[1])
        if usuarios_logueados == 0:
            # Apagar el ordenador
            subprocess.run(["sudo", "shutdown", "-h", "now"])
