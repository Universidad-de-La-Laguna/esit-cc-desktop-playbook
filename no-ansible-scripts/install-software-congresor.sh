apt install -y build-essential gfortran libcurl4-openssl-dev libssl-dev libxml2-dev libfontconfig1-dev libfreetype6-dev libharfbuzz-dev libfribidi-dev libpng-dev libjpeg-dev     libtiff5-dev libgit2-dev libudunits2-dev libgdal-dev libgeos-dev libproj-dev libsqlite3-dev libprotobuf-dev  protobuf-compiler

apt install -y r-base r-base-dev

wget https://ftp.esit.ull.es/ftp/packages/rstudio-2026.11.0-203-amd64.deb
apt install -y ./rstudio-2026.11.0-203-amd64.deb


# Primeros pasos R

## quarto
wget -q https://github.com/quarto-dev/quarto-cli/releases/download/v1.12.0/quarto-1.12.0-linux-amd64.deb -O /tmp/quarto.deb
apt-get install -y /tmp/quarto.deb
rm -f /tmp/quarto.deb
wget -qO- https://tinytex.yihui.org/install-bin-unix.sh | sh -s -- --no-path
mv /root/.TinyTeX /opt/TinyTeX
cd /opt/TinyTeX/bin/*
./tlmgr option sys_bin /usr/local/bin
./tlmgr path add
chmod -R a+rX /opt/TinyTeX



# usuario congreso 
useradd --create-home --shell /bin/bash congresor
echo "congresor:gofio-fosforo" | chpasswd --crypt-method SHA512
sudo -u congresor -H bash -c 'cd ~ ; git clone https://github.com/ElisaJorge/primeros-pasos-r.git'
chown -R congresor:congresor /home/congresor/primeros-pasos-r


R_LIB="/usr/local/lib/R/site-library"
mkdir -p /usr/local/lib/R/site-library
chmod 755 /usr/local/lib/R/site-library


R --vanilla --slave <<EOF
options(
  repos = c(CRAN = "https://cloud.r-project.org"),
  Ncpus = parallel::detectCores()
)

install.packages(
  c(
    "shiny",
    "bslib",
    "bsicons",
    "tidyverse",
    "palmerpenguins",
    "DT",
    "gt",
    "report",
    "leaflet",
    "plotly",
    "knitr",
    "rmarkdown",
    "mapSpain",
    "sf",
    "istacr"
  ),
  lib = "$R_LIB",
  dependencies = TRUE
)
EOF

## INE
R --vanilla --slave -e '
options(repos = c(CRAN = "https://cloud.r-project.org"))
install.packages(c("remotes", "data.table", "zip", "ranger"),
                 lib="/usr/local/lib/R/site-library",
                 dependencies=TRUE)
remotes::install_github("es-ine/rmlutils")
'



