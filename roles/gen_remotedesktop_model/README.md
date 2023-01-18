# Remote Desktop model generator

Este role genera sendos ficheros `.model` para la aplicación Microsoft Remote Desktop para qvitar tener que estar dando de alta uno a uno los equipos en dicha aplicación.

## Modo de uso

```sh
ansible <ccxx> -m include_role -a name=gen_remotedesktop_model --connection=local \
    -e remotedesktop_groupid=91292eab-1885-4c64-916f-cbb85a50b0c1
```

donde *ccxxx* se corresponde a la máquina o grupo de equipos a los que se les quiere crear el fichero de Remote Desktop.

El valor de *remotedesktop_groupid* corresponde al uuid del grupo de Remote Desktop donde se quiere añadir el equipo. Esos grupos son ficheros en la carpeta `C:\Users\bcuestav\AppData\Local\Packages\Microsoft.RemoteDesktop_8wekyb3d8bbwe\LocalState\RemoteDesktopData\groups`.

> IMPORTANTE: Revisar las variables `remotedesktop_credentialid` y `remotedesktop_connections_dir` del fichero `vars/main.yml` para establecer la credencial por defecto y el directorio de escritura de los ficheros. Más detalle en comentarios dentro del fichero.