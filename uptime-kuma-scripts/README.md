
# Monitorización del estado de los equipos mediante Uptime Kuma

## 1. Objetivo

El objetivo de este proyecto es desarrollar dos scripts, uno para **Windows** y otro para **Linux**, que permitan comprobar el estado de determinados componentes y recursos de los equipos y comunicar posibles incidencias a un servidor centralizado con **Uptime Kuma**.

La comunicación se realizará mediante peticiones HTTP utilizando `curl`, enviando los resultados de las comprobaciones al servidor para facilitar la detección de problemas y su posterior notificación por correo electrónico.

## 2. Funcionamiento general

Los scripts se ejecutarán automáticamente durante el arranque del sistema operativo. De esta manera, cada equipo realizará las comprobaciones definidas al iniciar y notificará al servidor de monitorización si detecta alguna incidencia.

El funcionamiento previsto es el siguiente:

1. El equipo inicia el sistema operativo.
2. Se ejecuta automáticamente el script correspondiente al sistema operativo instalado.
3. El script comprueba el estado de los componentes y recursos definidos.
4. Si se detecta una anomalía, se envía una petición HTTP mediante `curl` al servidor de Uptime Kuma.
5. Uptime Kuma recibe la información y permite gestionar la incidencia mediante los mecanismos de notificación configurados, como el envío de correos electrónicos.

## 3. Scripts por sistema operativo

Se desarrollarán dos scripts independientes para adaptarse a las características de cada sistema operativo.

### 3.1. Script para Linux

El script de Linux realizará comprobaciones sobre los recursos y componentes del sistema.

Entre las comprobaciones previstas se encuentra la disponibilidad de espacio en disco. Por ejemplo, se podrá generar una alerta cuando el espacio libre en el sistema de archivos raíz sea igual o inferior a 10 GB.

Si se detecta una condición de error, el script enviará un mensaje al servidor de Uptime Kuma indicando, como mínimo, el nombre del equipo, el sistema operativo, el problema detectado y los valores relevantes para identificar la incidencia.

### 3.2. Script para Windows

Se desarrollará un script equivalente para los equipos con Windows, adaptando las comprobaciones a las herramientas y características propias de este sistema operativo.

El objetivo será detectar problemas en los recursos definidos y enviar la información correspondiente al mismo servidor centralizado de monitorización mediante peticiones HTTP con `curl`.

Las comprobaciones concretas que se incorporarán al script de Windows se definirán durante su implementación.

## 4. Comunicación con Uptime Kuma

La comunicación con el servidor se realizará mediante el endpoint Push de Uptime Kuma.

Los scripts enviarán peticiones HTTP con los parámetros necesarios para identificar el estado y describir la incidencia detectada.

Los mensajes incluirán información que facilite la identificación del equipo afectado y el diagnóstico inicial del problema.

El servidor de Uptime Kuma centralizará la recepción de estas notificaciones y utilizará los canales de comunicación que se hayan configurado, como el correo electrónico.

## 5. Ejecución automática durante el arranque

Las comprobaciones se realizarán automáticamente al arrancar el sistema operativo, sin necesidad de intervención manual por parte del usuario.

Para ello, se configurará el mecanismo de inicio correspondiente en cada plataforma:

- **Linux:** mediante un servicio de `systemd` u otro mecanismo de inicio adecuado.
- **Windows:** mediante el Programador de tareas u otro mecanismo compatible con la ejecución automática durante el arranque.

Esta estrategia permitirá comprobar el estado de los equipos al inicio y comunicar las incidencias detectadas.

## 6. Alcance y consideraciones

La primera fase del proyecto estará centrada en la detección de problemas relacionados con los recursos del sistema, especialmente el espacio disponible en disco.

La solución se diseñará para que sea ampliable y permita incorporar nuevas comprobaciones en el futuro.

Se tendrán en cuenta los siguientes aspectos:

- Identificación del equipo que genera la alerta.
- Separación de la lógica específica de Windows y Linux.
- Configuración de umbrales para detectar condiciones anómalas.
- Envío de mensajes mediante peticiones HTTP con `curl`.
- Integración con las notificaciones configuradas en Uptime Kuma.
- Ejecución automática de las comprobaciones durante el arranque.
- Posibilidad de añadir nuevas verificaciones de recursos y componentes.

## 7. Resultado esperado

Se pretende disponer de un mecanismo sencillo y centralizado que permita detectar problemas en los equipos Windows y Linux desde el momento en que arrancan.

Mediante los scripts y Uptime Kuma, será posible identificar los equipos que presentan incidencias, conocer el motivo de la alerta y recibir una notificación por correo electrónico para facilitar su seguimiento y resolución.

La solución proporcionará una base común de monitorización para los dos sistemas operativos y permitirá ampliar progresivamente las comprobaciones según las necesidades de administración de los equipos.

**NOTA** Crear un script genérico que agrupe la llamada a scripts de comprobación. Ese script es el que debe agrupar todos los fallos y enviarlos por curl a uptime-kuma 
