#!/usr/bin/env bash

BASE="https://ull-esit-inf-dsi-2526.github.io"
ROOT="/typescript-theory"

mkdir -p mirror
cd mirror || exit 1

# incluir la página inicial
(
  echo "$ROOT/"

  curl -s "$BASE$ROOT/" \
    | grep -oP '(?<=href=")[^"]+' \
    | grep '^/' \
    | grep "^$ROOT"
) \
| sort -u \
| while read -r url; do

    file=$(echo "$url" | sed 's#^/##')

    # directorios -> index.html
    [[ "$file" =~ \.[a-zA-Z0-9]+$ ]] || file="$file/index.html"

    mkdir -p "$(dirname "$file")"

    echo "Descargando $url -> $file"

    single-file \
      "$BASE$url" \
      "$file"

done
