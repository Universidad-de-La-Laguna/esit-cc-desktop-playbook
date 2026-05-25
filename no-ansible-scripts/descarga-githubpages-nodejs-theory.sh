#!/usr/bin/env bash

BASE="https://ull-esit-inf-dsi-2526.github.io"
ROOT="/nodejs-theory"

mkdir -p mirror
cd mirror || exit 1

(
  echo "$ROOT/"

  curl -s "$BASE$ROOT/" \
    | grep -oP '(?<=href=")[^"]+' \
    | grep '^/' \
    | grep "^$ROOT"
) \
| sed 's/#.*//' \
| sort -u \
| while read -r url; do

    # quitar querystring
    clean_url="${url%%\?*}"

    file=$(echo "$clean_url" | sed 's#^/##')

    # si termina en / => index.html
    if [[ "$clean_url" =~ /$ ]]; then
        file="${file}index.html"
    fi

    mkdir -p "$(dirname "$file")"

    echo "Descargando $url -> $file"

    single-file \
      "$BASE$url" \
      "$file"

done
