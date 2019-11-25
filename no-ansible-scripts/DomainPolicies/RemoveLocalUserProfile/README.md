# RemoveLocalUserProfile

Script para el borrado de perfiles de usuario que tienen más de cierta antiguedad.

## Descarga

El script se ha obtenido directamente de este [enlace](https://gallery.technet.microsoft.com/scriptcenter/How-to-delete-user-d86ffd3c)

## Uso

### Listar los perfiles que llevan sin uso más de 30 días

```sh
C:\Script\RemoveLocalUserProfile.ps1 -ListUnusedDay 30
```

### Eliminar todos los perfiles sin usar de más de 30 días, excepto algunos usuarios

```sh
C:\Script\RemoveLocalUserProfile.ps1 -DeleteUnusedDay 30 -ExcludedUsers “etsii,invitado”
```