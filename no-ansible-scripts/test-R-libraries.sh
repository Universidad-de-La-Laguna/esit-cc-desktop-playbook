#!/bin/bash

HOSTNAME=$(hostname)

echo "$HOSTNAME"

if R --vanilla --slave >/dev/null 2>&1 <<'EOF'
library(shiny)
library(bslib)
library(bsicons)
library(tidyverse)
library(palmerpenguins)
library(DT)
library(gt)
library(report)
library(leaflet)
library(plotly)
library(knitr)
library(rmarkdown)
library(mapSpain)
library(sf)
library(istacr)
library(remotes)
library(data.table)
library(zip)
library(ranger)
library(RMLutils)
EOF
then
    echo "OK"
else
    echo -e "\033[31mFAIL\033[0m"
fi
