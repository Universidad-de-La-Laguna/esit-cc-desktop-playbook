#!/usr/bin/env bash

set -u

ERRORS=()

fail() {
    ERRORS+=("$1")
}

check_cmd() {
    command -v "$1" >/dev/null 2>&1 || fail "$2"
}

echo -n "Comprobando instalación... "

check_cmd R "R no instalado"
check_cmd rstudio "RStudio no instalado"
check_cmd quarto "Quarto no instalado"
check_cmd git "Git no instalado"
check_cmd pdflatex "TinyTeX/pdflatex no instalado"

# Usuario
id congresor >/dev/null 2>&1 || fail "Usuario congresor no existe"

# Repositorio
if [ -d /home/congresor/primeros-pasos-r/.git ]; then
    [ "$(stat -c %U /home/congresor/primeros-pasos-r)" = "congresor" ] ||
        fail "El repositorio no pertenece a congresor"
else
    fail "Repositorio primeros-pasos-r no encontrado"
fi

# Paquetes R como usuario normal
if command -v R >/dev/null 2>&1 && id congresor >/dev/null 2>&1; then
    if ! sudo -u congresor -H R --vanilla --slave <<'EOF' >/dev/null 2>&1
packages <- c(
    "shiny", "bslib", "bsicons", "tidyverse",
    "palmerpenguins", "DT", "gt", "report",
    "leaflet", "plotly", "knitr", "rmarkdown",
    "mapSpain", "sf", "istacr",
    "remotes", "data.table", "zip", "ranger", "RMLutils"
)

if (!all(vapply(packages, requireNamespace, logical(1), quietly = TRUE))) {
    quit(status = 1)
}
EOF
    then
        fail "Faltan paquetes R"
    fi
fi

# Quarto como usuario normal
if command -v quarto >/dev/null 2>&1 && id congresor >/dev/null 2>&1; then
    sudo -u congresor -H quarto check >/dev/null 2>&1 ||
        fail "Quarto no funciona para congresor"
fi

# TinyTeX como usuario normal
if command -v pdflatex >/dev/null 2>&1 && id congresor >/dev/null 2>&1; then
    sudo -u congresor -H pdflatex --version >/dev/null 2>&1 ||
        fail "pdflatex no funciona para congresor"
fi

if [ "${#ERRORS[@]}" -eq 0 ]; then
    echo "OK"
    exit 0
fi

echo "ERROR"
printf '  - %s\n' "${ERRORS[@]}"
exit 1

