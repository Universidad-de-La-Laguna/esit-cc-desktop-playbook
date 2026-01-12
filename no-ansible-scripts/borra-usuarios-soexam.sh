#!/bin/bash

# Borrar usuarios que comienzan por "soexam"
for usuario in $(awk -F: '$1 ~ /^soexam/ {print $1}' /etc/passwd); do
    userdel -r "$usuario"
    echo "Borrado: $usuario"
done