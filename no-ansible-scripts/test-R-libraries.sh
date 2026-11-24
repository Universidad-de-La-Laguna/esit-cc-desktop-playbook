#!/bin/bash

R --vanilla --slave <<'EOF'
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
