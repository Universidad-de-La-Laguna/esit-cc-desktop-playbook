# desktop-playbook
Ansible playbooks para instalacion con ansible-pull

## Copia de la clave pública para conexión remota a equipos del CC

Para copiar la clave pública y poder acceder remotamente al equipo `ccxxxx` utilizar el siguiente comando:

```sh
ssh-copy-id -i ~/.ssh/ansible_rsa.pub root@ccxxxx.etsii.ull.es
```

> Nota: El fichero `ansible_rsa.pub` se encuentra en la carpeta `resources/ansible` y se tiene que copiar en `~/.ssh` (carpeta `.ssh` del home del usuario) y ponerle los permisos `644`.

> Para la conexión remota se necesita también que la clave privada esté en el fichero `~/.ssh/ansible_rsa`. El contenido del fichero de la clave privada se puede consultar el el [Keeweb](http://app.keeweb.info/)