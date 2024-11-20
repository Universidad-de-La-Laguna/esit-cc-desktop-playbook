# Rol Ansible: instalar_dependencias

Este rol instala las dependencias `pymunk` y `pygame` usando `pip` y configura la variable de entorno 
`PROTOCOL_BUFFERS_PYTHON_IMPLEMENTATION=python` de forma permanente en `/etc/profile.d/set_protobuf_env.sh`.

## Variables Exportadas
- `PROTOCOL_BUFFERS_PYTHON_IMPLEMENTATION=python`
